// Per-monitor wallpaper overlay for Omarchy.
//
// The stock Omarchy background service paints one image on every output, so it
// cannot show a different wallpaper per screen. This third-party service maps a
// wallpaper to each screen *orientation* and renders it on the bottom layer,
// above the first-party background but below application windows. Same-layer
// mapping order is not reliable after monitor rotation or repositioning.
//
// Landscape screens keep the stock wallpaper (this surface stays transparent),
// but the panel still takes the background double-click so it can open the
// per-monitor picker instead of the all-screens one. Portrait screens get the
// image from the state file.
//
// State: ~/.config/omarchy/monitor-wallpapers.json
//   { "portrait": "/path/to/tall.jpg" }
//
// Keying on orientation rather than connector name survives the DisplayPort MST
// hub renumbering this machine sees (DP-12/DP-7 <-> DP-13/DP-8).

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

Item {
  id: root

  readonly property string stateHome: Quickshell.env("HOME") + "/.config/omarchy"
  readonly property string statePath: stateHome + "/monitor-wallpapers.json"

  property var mapping: ({})

  function slotFor(screen) {
    if (!screen) return ""
    return screen.height > screen.width ? "portrait" : "landscape"
  }

  function pathFor(slot) {
    var path = slot !== "" && mapping ? mapping[slot] : ""
    return String(path || "")
  }

  function parseState(raw) {
    try {
      var data = JSON.parse(String(raw || "{}"))
      mapping = (data && typeof data === "object") ? data : ({})
    } catch (e) {
      mapping = ({})
    }
  }

  function pickForSlot(slot) {
    if (!slot || pickProcess.running) return
    pickProcess.command = ["bash", "-lc", "wallpaper-monitor-pick " + slot]
    pickProcess.running = true
  }

  function openThemeSwitcher() {
    if (themeProcess.running) return
    themeProcess.running = true
  }

  FileView {
    id: stateFile
    path: root.statePath
    watchChanges: true
    printErrors: false
    onLoaded: root.parseState(text())
    onFileChanged: stateFile.reload()
    onLoadFailed: root.mapping = ({})
  }

  Process {
    id: pickProcess
    onExited: stateFile.reload()
  }

  Process {
    id: themeProcess
    command: ["bash", "-lc", "theme=$(omarchy-theme-switcher); [[ -n $theme ]] && omarchy-theme-set \"$theme\" >/dev/null 2>&1 &"]
  }

  IpcHandler {
    target: "monitor-wallpaper"

    function refresh(): void {
      stateFile.reload()
    }
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: panel
      required property var modelData

      readonly property string slot: root.slotFor(modelData)
      readonly property string imagePath: root.pathFor(panel.slot)

      screen: modelData
      visible: true
      color: "transparent"
      anchors { top: true; bottom: true; left: true; right: true }
      exclusionMode: ExclusionMode.Ignore

      WlrLayershell.layer: WlrLayer.Bottom
      WlrLayershell.namespace: "omarchy-monitor-wallpaper"
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

      Image {
        anchors.fill: parent
        visible: panel.imagePath !== ""
        source: panel.imagePath ? "file://" + panel.imagePath : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
      }

      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onDoubleClicked: function(mouse) {
          if (mouse.button === Qt.RightButton) root.openThemeSwitcher()
          else root.pickForSlot(panel.slot)
          mouse.accepted = true
        }
      }
    }
  }
}
