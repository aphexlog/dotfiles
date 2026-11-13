pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
  id: root
  property real clickX: 0
  property string output: ""
  property string edge: "top"
  property double timestamp: 0
  property var activeOwner: null
  readonly property color background: "#080f1b"
  readonly property color foreground: "#d8f7ff"
  readonly property color cyan: "#00e5ff"
  readonly property color magenta: "#f072ff"
  readonly property bool recent: Date.now() - timestamp < 1500

  function snapshot() {
    // Evaluate the clock here, not just in a cached QML property binding.
    return {active: Date.now() - timestamp < 1500, x: clickX, output: output, edge: edge}
  }
  function screenFor(name) {
    for (var i = 0; i < Quickshell.screens.length; i++)
      if (Quickshell.screens[i].name === name) return Quickshell.screens[i]
    return null
  }
  function claim(owner) {
    if (activeOwner && activeOwner !== owner && typeof activeOwner.close === "function")
      activeOwner.close()
    activeOwner = owner
  }
}
