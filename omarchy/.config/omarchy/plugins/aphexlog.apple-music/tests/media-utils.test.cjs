const assert = require('node:assert/strict')
const { readFileSync } = require('node:fs')
const { join } = require('node:path')
const { test } = require('node:test')
const vm = require('node:vm')

const media = vm.createContext({})
vm.runInContext(readFileSync(join(__dirname, '..', 'MediaUtils.js'), 'utf8'), media)
const browser = { identity: 'Chromium', desktopEntry: 'chromium', metadata: {} }
const apple = { ...browser, trackArtUrl: 'https://is1-ssl.mzstatic.com/image/thumb/Music/cover.jpg' }

test('only Apple sessions are selected among multiple browser players', () => {
  const youtube = { ...browser, isPlaying: true, trackArtUrl: 'https://lh3.googleusercontent.com/cover' }
  const playingApple = { ...apple, isPlaying: true }
  assert.equal(media.selectPlayer([youtube, apple, playingApple]), playingApple)
  assert.equal(media.selectPlayer([youtube, apple]), apple)
  assert.equal(media.selectPlayer([youtube, browser]), null)
  assert.equal(media.selectPlayer([]), null)
})

test('URL-only sessions and native clients work without artwork', () => {
  assert.equal(media.isApplePlayer({ ...browser, metadata: { 'xesam:url': 'https://music.apple.com/us/album/123' } }), true)
  assert.equal(media.isApplePlayer({ identity: 'Cider', metadata: {} }), true)
  assert.equal(media.isApplePlayer({ identity: 'Apple Music', metadata: {} }), true)
})

test('foreign hosts and artwork embedded in query strings cannot select Apple', () => {
  for (const url of ['https://music.apple.com.evil.test/song', 'https://evil.test/?url=https://music.apple.com/', 'https://music.apple.com@evil.test/']) {
    assert.equal(media.isApplePlayer({ ...browser, metadata: { 'xesam:url': url } }), false)
  }
  for (const url of ['https://mzstatic.com.evil.test/art', 'https://evil.test/?art=mzstatic.com/', 'http://is1-ssl.mzstatic.com/art', 'file:///tmp/art']) {
    assert.equal(media.isApplePlayer({ ...browser, trackArtUrl: url }), false)
    assert.equal(media.appleArtwork(url), '')
  }
})

test('Waybar markup-shaped titles and artists remain literal text', () => {
  const title = '<img src="https://example.invalid/tracker"> & <b>song</b>'
  const artist = "<span foreground='red'>artist</span>"
  const status = media.waybarStatus({ ...apple, trackTitle: title, trackArtist: artist }, 'Click: player')
  assert.equal(status.text.includes(title), true) // Waybar escape:true handles the label.
  assert.equal(/[<>]/.test(status.tooltip), false)
  assert.match(status.tooltip, /&lt;img src=&quot;/)
  assert.match(status.tooltip, /&amp;/)
  assert.match(status.tooltip, /&apos;red&apos;/)
  assert.equal(JSON.parse(JSON.stringify(status)).class, 'paused')
  assert.equal(media.cleanText('x'.repeat(1000)).length, 512)
  assert.equal(media.cleanText('one\nline\u0000'), 'one line ')
})

test('disconnect and playback changes have explicit toolbar states', () => {
  assert.equal(media.waybarStatus(null, '').class, 'idle')
  assert.equal(media.waybarStatus({ ...apple, isPlaying: true }, '').class, 'playing')
  assert.equal(media.waybarStatus(apple, '').class, 'paused')
})
