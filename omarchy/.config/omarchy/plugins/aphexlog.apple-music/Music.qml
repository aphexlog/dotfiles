pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import qs.Commons
import "MediaUtils.js" as MediaUtils

// One media controller and IPC endpoint shared by both monitor widgets.
Scope {
  id: root

  readonly property var player: MediaUtils.selectPlayer(Mpris.players.values)
  property var bridge: ({})
  property real now: Date.now()
  property real nativePosition: 0
  property string errorMessage: ""
  property var pendingCommand: null
  property real beforeMute: 0.5
  readonly property string stateDir: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/apple-music-player"
  readonly property string host: Quickshell.env("HOME") + "/.config/omarchy/plugins/aphexlog.apple-music/bridge/host.py"
  readonly property bool bridgeOn: bridge.service === "apple-music" && bridge.connected === true && now - Number(bridge.ts || 0) * 1000 < 10000
  readonly property bool connected: bridgeOn || player !== null
  readonly property bool playing: bridgeOn ? bridge.playing === true : player !== null && player.isPlaying
  readonly property string title: MediaUtils.cleanText(bridgeOn ? bridge.title : player ? player.trackTitle : "")
  readonly property string artist: MediaUtils.cleanText(bridgeOn ? bridge.artist : player ? player.trackArtist : "")
  readonly property string album: MediaUtils.cleanText(bridgeOn ? bridge.album : player ? player.trackAlbum : "")
  readonly property string artwork: MediaUtils.appleArtwork(bridgeOn ? bridge.art : player ? player.trackArtUrl : "")
  readonly property real length: bridgeOn ? Number(bridge.duration || 0) : player && player.lengthSupported ? Math.max(0, player.length) : 0
  readonly property real position: bridgeOn ? Number(bridge.position || 0) : nativePosition
  readonly property bool browser: bridgeOn || (player !== null && MediaUtils.isBrowser(player))
  readonly property bool canPlay: bridgeOn ? bridge.canPlay === true : player !== null && player.canTogglePlaying
  readonly property bool canNext: bridgeOn ? bridge.canNext === true : player !== null && player.canGoNext
  readonly property bool canPrevious: bridgeOn ? bridge.canPrevious === true : player !== null && player.canGoPrevious
  readonly property bool canSeek: bridgeOn ? bridge.canSeek === true : player !== null && player.canSeek
  readonly property bool canShuffle: bridgeOn ? bridge.canShuffle === true : player !== null && player.shuffleSupported
  readonly property bool canRepeat: bridgeOn ? bridge.canRepeat === true : player !== null && player.loopSupported
  readonly property bool shuffle: bridgeOn ? bridge.shuffle === true : player !== null && player.shuffle
  readonly property string repeat: bridgeOn ? String(bridge.repeat || "NONE") : player && player.loopState === MprisLoopState.Track ? "ONE"
    : player && player.loopState === MprisLoopState.Playlist ? "ALL" : "NONE"
  readonly property bool hasVolume: bridgeOn ? bridge.canVolume === true : player !== null && !browser && player.volumeSupported
  readonly property real volume: bridgeOn ? Number(bridge.volume || 0) : hasVolume ? player.volume : 0
  readonly property var queue: bridgeOn && Array.isArray(bridge.queue) ? bridge.queue : []

  Translations { id: strings; directory: Qt.resolvedUrl("i18n") }

  Timer {
    interval: 1000; running: true; repeat: true
    onTriggered: {
      root.now = Date.now()
      if (root.player && !root.bridgeOn && root.player.positionSupported) {
        root.player.positionChanged()
        root.nativePosition = Math.max(0, root.player.position)
      }
    }
  }
  FileView {
    path: root.stateDir + "/state.json"
    watchChanges: true; printErrors: false
    onFileChanged: reload()
    onLoaded: { try { root.bridge = JSON.parse(text()); root.now = Date.now() } catch (_) {} }
  }
  FileView {
    path: root.stateDir + "/result.json"
    watchChanges: true; printErrors: false
    onFileChanged: reload()
    onLoaded: {
      try {
        var result = JSON.parse(text())
        if (Date.now() / 1000 - result.ts < 10) root.errorMessage = result.ok ? "" : MediaUtils.cleanText(result.error)
      } catch (_) {}
    }
  }
  Process {
    id: writer
    stdout: StdioCollector {
      onStreamFinished: {
        try { var result = JSON.parse(text); if (!result.ok) root.errorMessage = result.error } catch (_) {}
      }
    }
    onExited: {
      if (root.pendingCommand) {
        var request = root.pendingCommand
        root.pendingCommand = null
        root.send(request)
      }
    }
  }
  function send(request) {
    if (writer.running) { pendingCommand = request; return }
    errorMessage = ""
    writer.command = ["python3", host, "--send", JSON.stringify(request)]
    writer.running = true
  }

  function togglePlay() {
    if (bridgeOn) send({cmd: "toggle"})
    else if (root.player && root.player.canTogglePlaying) root.player.togglePlaying()
  }
  function nextTrack() {
    if (bridgeOn) send({cmd: "next"})
    else if (root.player && root.player.canGoNext) root.player.next()
  }
  function previousTrack() {
    if (bridgeOn) send({cmd: "previous"})
    else if (root.player && root.player.canGoPrevious) root.player.previous()
  }
  function seekTo(seconds) {
    if (bridgeOn && isFinite(seconds)) send({cmd: "seek", value: Math.max(0, Math.min(length, seconds))})
    else if (root.player && root.player.canSeek && isFinite(seconds))
      root.player.position = Math.max(0, Math.min(root.length, seconds))
  }
  function toggleShuffle() {
    if (bridgeOn) send({cmd: "shuffle"})
    else if (root.player && root.player.canControl && root.player.shuffleSupported)
      root.player.shuffle = !root.player.shuffle
  }
  function cycleRepeat() {
    if (bridgeOn) { send({cmd: "repeat"}); return }
    if (!root.player || !root.player.canControl || !root.player.loopSupported) return
    root.player.loopState = root.player.loopState === MprisLoopState.None ? MprisLoopState.Playlist
      : root.player.loopState === MprisLoopState.Playlist ? MprisLoopState.Track : MprisLoopState.None
  }
  function setVolume(value) {
    if (bridgeOn && isFinite(value)) send({cmd: "volume", value: Math.max(0, Math.min(1, value))})
    else if (root.hasVolume && root.player.canControl && isFinite(value))
      root.player.volume = Math.max(0, Math.min(1, value))
  }
  function toggleMute() {
    if (volume > 0) { beforeMute = volume; setVolume(0) }
    else setVolume(beforeMute || 0.5)
  }
  function openApp() {
    if (!bridgeOn && root.player && root.player.canRaise) {
      root.player.raise()
      return
    }
    Quickshell.execDetached(["omarchy-launch-or-focus", "chrome-music\\.apple\\.com__.*",
      "uwsm-app -- chromium --profile-directory=Default --app=https://music.apple.com/"])
  }
  function status() {
    return JSON.stringify(MediaUtils.waybarStatus(connected ? {trackTitle: title, trackArtist: artist, isPlaying: playing} : null,
      strings.t("player.controls")))
  }

  ShellIpc {
    target: "apple-music-player"
    function status(): string { return root.status() }
    function state(): string {
      return JSON.stringify({service: "apple-music", connected: root.connected, bridge: root.bridgeOn, title: root.title,
        artist: root.artist, playing: root.playing, position: root.position, duration: root.length, volume: root.volume,
        artwork: root.artwork, canPlay: root.canPlay, canSeek: root.canSeek, error: root.errorMessage})
    }
    function toggle(): void { root.togglePlay() }
    function next(): void { root.nextTrack() }
    function previous(): void { root.previousTrack() }
    function launch(): void { root.openApp() }
  }
}
