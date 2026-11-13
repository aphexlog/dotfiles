pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import qs.Commons
import "MediaUtils.js" as MediaUtils

// Share one Cliamp controller and IPC endpoint across both monitor widgets.
Scope {
  id: root

  readonly property var player: MediaUtils.selectPlayer(Mpris.players.values)
  readonly property bool connected: player !== null
  readonly property bool playing: connected && player.isPlaying
  readonly property string state: !connected ? "idle" : playing ? "playing"
    : player.playbackState === MprisPlaybackState.Paused ? "paused" : "stopped"
  readonly property string title: connected ? MediaUtils.cleanText(player.trackTitle) : ""
  readonly property string artist: connected ? MediaUtils.cleanText(player.trackArtist) : ""
  readonly property string album: connected ? MediaUtils.cleanText(player.trackAlbum) : ""
  readonly property real length: connected && player.lengthSupported && isFinite(player.length) ? Math.max(0, player.length) : 0
  readonly property real position: connected && player.positionSupported && isFinite(player.position) ? Math.max(0, player.position) : 0
  readonly property bool canPlay: connected && player.canControl && player.canTogglePlaying
  readonly property bool canNext: connected && player.canControl && player.canGoNext
  readonly property bool canPrevious: connected && player.canControl && player.canGoPrevious
  readonly property bool canSeek: connected && player.canControl && player.canSeek && length > 0
  readonly property bool hasVolume: connected && player.canControl && player.volumeSupported
  readonly property real volume: hasVolume && isFinite(player.volume) ? Math.max(0, Math.min(1, player.volume)) : 0
  property real beforeMute: 0.5

  Translations { id: strings; directory: Qt.resolvedUrl("i18n") }

  // MPRIS updates metadata directly; this only refreshes its interpolated clock.
  Timer {
    interval: 1000
    running: root.playing
    repeat: true
    triggeredOnStart: true
    onTriggered: if (root.player && root.player.positionSupported) root.player.positionChanged()
  }

  function togglePlay() {
    if (canPlay) player.togglePlaying()
  }
  function nextTrack() {
    if (canNext) player.next()
  }
  function previousTrack() {
    if (canPrevious) player.previous()
  }
  function seekTo(seconds) {
    if (canSeek && isFinite(seconds)) player.position = Math.max(0, Math.min(length, seconds))
  }
  function setVolume(value) {
    if (hasVolume && isFinite(value)) player.volume = Math.max(0, Math.min(1, value))
  }
  function toggleMute() {
    if (volume > 0) { beforeMute = volume; setVolume(0) }
    else setVolume(beforeMute || 0.5)
  }
  function openApp() {
    Quickshell.execDetached(["omarchy", "launch", "or-focus", "(^org\\.omarchy\\.cliamp$|.*\\| cliamp$|^cliamp$)",
      "omarchy launch tui --app-id=org.omarchy.cliamp cliamp"])
  }
  function status() {
    return JSON.stringify(MediaUtils.waybarStatus(connected, state, title, artist, strings.t("player.controls")))
  }

  ShellIpc {
    target: "cliamp-player"
    function status(): string { return root.status() }
    function state(): string {
      return JSON.stringify({connected: root.connected, state: root.state, title: root.title,
        artist: root.artist, album: root.album, position: root.position, duration: root.length,
        volume: root.volume, canPlay: root.canPlay, canNext: root.canNext,
        canPrevious: root.canPrevious, canSeek: root.canSeek, hasVolume: root.hasVolume})
    }
    function toggle(): void { root.togglePlay() }
    function next(): void { root.nextTrack() }
    function previous(): void { root.previousTrack() }
    function volume(value: real): void { root.setVolume(value) }
    function seek(value: real): void { root.seekTo(value) }
    function launch(): void { root.openApp() }
  }
}
