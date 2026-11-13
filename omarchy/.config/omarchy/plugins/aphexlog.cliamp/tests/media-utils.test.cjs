const assert = require('node:assert/strict')
const { readFileSync } = require('node:fs')
const { join } = require('node:path')
const { test } = require('node:test')
const vm = require('node:vm')

const media = vm.createContext({})
vm.runInContext(readFileSync(join(__dirname, '..', 'MediaUtils.js'), 'utf8'), media)

test('Cliamp controls never select another music app or a similarly named session', () => {
  const browser = { dbusName: 'org.mpris.MediaPlayer2.chromium', identity: 'Cliamp', isPlaying: true }
  const impostor = { dbusName: 'org.mpris.MediaPlayer2.cliamp_other', isPlaying: true }
  const paused = { dbusName: 'org.mpris.MediaPlayer2.cliamp', isPlaying: false }
  const playing = { dbusName: 'org.mpris.MediaPlayer2.cliamp.instance42', isPlaying: true }
  assert.equal(media.selectPlayer([browser, impostor, paused]), paused)
  assert.equal(media.selectPlayer([paused, browser, playing]), playing)
  assert.equal(media.selectPlayer([browser, impostor, null]), null)
  assert.equal(media.selectPlayer([]), null)
})

test('markup-shaped metadata and tooltip controls remain bounded literal text', () => {
  const title = '<img src="https://example.invalid/tracker"> & <b>song</b>'
  const artist = "<span foreground='red'>artist</span>"
  const status = media.waybarStatus(true, 'playing', title, artist, '<b>Click</b>')
  assert.equal(/[<>]/.test(status.tooltip), false)
  assert.match(status.tooltip, /&lt;img src=&quot;/)
  assert.match(status.tooltip, /&amp;/)
  assert.match(status.tooltip, /&apos;red&apos;/)
  assert.match(status.tooltip, /&lt;b&gt;Click&lt;\/b&gt;/)
  assert.equal(media.cleanText('x'.repeat(1000)).length, 512)
  assert.equal(media.cleanText('one\nline\u0000'), 'one line ')
})

test('disconnect clears stale track information and distinguishes playback states', () => {
  const idle = media.waybarStatus(false, 'playing', 'old song', 'old artist', 'Click')
  assert.equal(idle.class, 'idle')
  assert.equal(idle.tooltip.includes('old'), false)
  for (const state of ['playing', 'paused', 'stopped']) {
    assert.equal(media.waybarStatus(true, state, '', '', '').class, state)
  }
})
