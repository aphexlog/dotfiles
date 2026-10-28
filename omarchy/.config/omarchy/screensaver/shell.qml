import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

ShellRoot {
  id: root

  // Shared timing keeps every display on the same transmission.
  readonly property bool preview: Quickshell.env("PIRATE_PREVIEW") === "1"
  readonly property color neon: "#63f5ed"
  readonly property color magenta: "#f275cf"
  property date clock: new Date()
  property int transmission: 0
  property bool armed: false
  property bool glitch: false
  property real seaPhase: 0
  property real particlePhase: 0
  readonly property var messages: [
    "HOLOGRAPHIC LINK / GHOST SIGNAL ACTIVE",
    "SCANNING THE VOID / NO PURSUIT DETECTED",
    "BLACK FLAG PROTOCOL / RUNNING SILENT",
    "CREW IN STASIS / SYSTEMS NOMINAL",
  ]

  NumberAnimation on seaPhase {
    from: 0; to: 1; duration: 4200; loops: Animation.Infinite
  }
  NumberAnimation on particlePhase {
    from: 0; to: 1; duration: 60000; loops: Animation.Infinite
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: root.clock = new Date()
  }
  Timer {
    interval: 1200
    running: true
    onTriggered: root.armed = true
  }
  Timer {
    interval: 11000
    running: true
    repeat: true
    onTriggered: {
      root.transmission++
      root.glitch = true
      glitchEnd.restart()
    }
  }
  Timer {
    id: glitchEnd
    interval: 110
    onTriggered: root.glitch = false
  }

  // A normal toplevel preserves Omarchy's screensaver-window idle tracking.
  // Leave immediately when another app takes focus; never act as a lock screen.
  Connections {
    target: Hyprland
    function onRawEvent(event) {
      if (!root.preview && root.armed && event.name === "activewindow") {
        const app = event.data.split(",")[0]
        if (app !== "org.omarchy.screensaver") Qt.quit()
      }
    }
  }
  IpcHandler {
    target: "screensaver"
    function dismiss(): void { Qt.quit() }
  }
  Timer {
    interval: Number(Quickshell.env("PIRATE_PREVIEW_SECONDS") || "0") * 1000
    running: interval > 0
    onTriggered: Qt.quit()
  }

  Variants {
    model: root.preview ? Quickshell.screens.slice(0, 1) : Quickshell.screens

    FloatingWindow {
      id: window
      required property var modelData
      screen: modelData
      title: "SOL // GHOST SIGNAL // " + modelData.name
      visible: true
      fullscreen: !root.preview
      implicitWidth: 1280
      implicitHeight: 800
      color: "#060b13"

      // Hyprland initially maps all Qt windows on the focused output. Move each
      // to its own output before requesting fullscreen again.
      Connections {
        target: Hyprland
        function onRawEvent(event) {
          if (root.preview || event.name !== "openwindow") return
          const parts = event.data.split(",")
          if (parts[2] === "org.omarchy.screensaver" && parts.slice(3).join(",") === window.title) {
            Hyprland.dispatch("hl.dsp.window.move({ window = " + JSON.stringify("address:0x" + parts[0]) + ", monitor = " + JSON.stringify(window.modelData.name) + " })")
            window.fullscreen = false
            settle.restart()
          }
        }
      }
      Timer {
        id: settle
        interval: 250
        onTriggered: window.fullscreen = true
      }

      Item {
        id: canvas
        anchors.fill: parent
        focus: true
        clip: true
        Keys.onPressed: event => {
          event.accepted = true
          Qt.quit()
        }

        // Low-contrast grid and scanlines echo the secure-terminal artwork.
        Repeater {
          model: Math.ceil(canvas.width / 80)
          Rectangle {
            required property int index
            x: index * 80
            width: 1
            height: canvas.height
            color: "#0d1b27"
          }
        }
        Repeater {
          model: Math.ceil(canvas.height / 5)
          Rectangle {
            required property int index
            y: index * 5
            width: canvas.width
            height: 1
            color: index % 16 === 0 ? "#0d1b27" : "#090f19"
          }
        }

        // Perspective ocean: lines travel toward the viewer beneath the ship.
        Repeater {
          model: 16
          Rectangle {
            required property int index
            readonly property real depth: ((index + root.seaPhase) % 16) / 16
            x: 0
            y: canvas.height * (0.65 + 0.35 * depth * depth)
            width: canvas.width
            height: 1
            color: root.neon
            opacity: 0.025 + depth * 0.09
          }
        }
        Repeater {
          model: 21
          Rectangle {
            required property int index
            x: canvas.width / 2
            y: canvas.height * 0.65
            width: 1
            height: canvas.height
            color: root.neon
            opacity: 0.05
            transformOrigin: Item.Top
            rotation: (index - 10) * 7
          }
        }

        // Sparse ion particles rise at different speeds without a shader/video.
        Repeater {
          model: 42
          Rectangle {
            id: particle
            required property int index
            x: ((index * 7919) % 1000) / 1000 * canvas.width
            y: (1 - ((root.particlePhase * (2 + index % 3) + index * 0.137) % 1)) * (canvas.height + 60) - 30
            width: index % 5 === 0 ? 3 : 1
            height: index % 5 === 0 ? 3 : 13
            color: index % 6 === 0 ? root.magenta : root.neon
            opacity: 0.08 + (index % 5) * 0.045
          }
        }
        Rectangle {
          width: canvas.width
          height: 100
          opacity: 0.07
          gradient: Gradient {
            GradientStop { position: 0; color: "transparent" }
            GradientStop { position: 1; color: root.neon }
          }
          Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: root.neon
          }
          NumberAnimation on y {
            from: -100
            to: canvas.height
            duration: 18000
            loops: Animation.Infinite
          }
        }

        Item {
          id: scene
          readonly property bool portrait: canvas.height > canvas.width
          width: portrait ? 700 : 1180
          height: portrait ? 1100 : 720
          scale: Math.max(0.1, Math.min(1.8, (canvas.width - 100) / width, (canvas.height - 160) / height))
          x: (canvas.width - width) / 2 + driftX
          y: (canvas.height - height) / 2 + driftY
          property real driftX: 0
          property real driftY: 0

          // Gentle scene drift avoids a permanently fixed centerpiece.
          SequentialAnimation on driftX {
            loops: Animation.Infinite
            NumberAnimation { to: 24; duration: 29000; easing.type: Easing.InOutSine }
            NumberAnimation { to: -24; duration: 58000; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0; duration: 29000; easing.type: Easing.InOutSine }
          }
          SequentialAnimation on driftY {
            loops: Animation.Infinite
            NumberAnimation { to: -18; duration: 37000; easing.type: Easing.InOutSine }
            NumberAnimation { to: 18; duration: 74000; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0; duration: 37000; easing.type: Easing.InOutSine }
          }

          Item {
            id: emblem
            x: scene.portrait ? 70 : 0
            y: scene.portrait ? 25 : 30
            width: 560
            height: 620
            opacity: root.glitch ? 0.78 : 1
            transform: Translate { x: root.glitch ? 3 : 0 }

            // A separate holographic corsair, not the lock screen's skull.
            Image {
              anchors.fill: parent
              source: Qt.resolvedUrl("ghost-ship.svg")
              sourceSize.width: Math.ceil(width * scene.scale)
              sourceSize.height: Math.ceil(height * scene.scale)
            }
            Rectangle {
              x: 162; y: 479
              width: 258; height: 17; radius: 8
              color: root.magenta
              SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { from: 0.015; to: 0.17; duration: 2400; easing.type: Easing.InOutSine }
                NumberAnimation { to: 0.015; duration: 3400; easing.type: Easing.InOutSine }
              }
            }
            Rectangle {
              x: 24; y: 29
              width: 512; height: 512; radius: 256
              color: "transparent"
              border.color: root.neon
              border.width: 1
              opacity: 0.4
              SequentialAnimation on scale {
                loops: Animation.Infinite
                NumberAnimation { from: 0.85; to: 1.12; duration: 4000; easing.type: Easing.OutSine }
                PauseAnimation { duration: 1800 }
              }
              SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { from: 0.4; to: 0; duration: 4000 }
                PauseAnimation { duration: 1800 }
              }
            }

            // Rotating radar arm and range ticks frame the projected vessel.
            Item {
              x: 40; y: 45; width: 480; height: 480
              NumberAnimation on rotation {
                from: 0; to: 360; duration: 16000; loops: Animation.Infinite
              }
              Rectangle {
                x: 239; y: 0; width: 1; height: 240
                color: root.neon; opacity: 0.25
              }
              Rectangle {
                x: 235; y: -4; width: 9; height: 9; radius: 5
                color: root.neon; opacity: 0.7
              }
            }
            Repeater {
              model: 3
              Rectangle {
                required property int index
                visible: root.glitch
                x: index % 2 ? 54 : 20
                y: 190 + index * 97
                width: 490 - index * 70
                height: index === 1 ? 5 : 2
                color: index === 1 ? root.magenta : root.neon
                opacity: 0.35
              }
            }
          }

          Column {
            x: scene.portrait ? 70 : 650
            y: scene.portrait ? 710 : 170
            spacing: 23

            Text {
              text: "SOL  //  VOID CORSAIR"
              color: root.neon
              font { family: "monospace"; pixelSize: 14; letterSpacing: 3 }
            }
            Text {
              text: Qt.formatDateTime(root.clock, "HH:mm")
              color: "#e0f8f6"
              font { family: "monospace"; pixelSize: 88; weight: Font.Light; letterSpacing: -4 }
            }
            Text {
              text: root.glitch ? "GHØST / SHIP_" : "GHOST SHIP"
              color: root.magenta
              font { family: "monospace"; pixelSize: 19; letterSpacing: 6 }
            }
            Rectangle { width: 430; height: 1; color: "#244451" }
            Text {
              text: root.messages[root.transmission % root.messages.length]
              color: "#71909e"
              font { family: "monospace"; pixelSize: 11; letterSpacing: 1 }
            }
            Row {
              spacing: 5
              Repeater {
                model: 32
                Rectangle {
                  required property int index
                  width: 8
                  height: 3 + ((index * 7 + root.transmission * 3) % 13)
                  color: index % 7 === 0 ? root.magenta : root.neon
                  opacity: 0.18 + ((index + root.transmission) % 5) * 0.12
                }
              }
            }
            Text {
              text: Qt.formatDateTime(root.clock, "ddd, dd MMM yyyy").toUpperCase()
              color: "#47616f"
              font { family: "monospace"; pixelSize: 11; letterSpacing: 2 }
            }
          }
        }

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.BlankCursor
          property point lastPosition: Qt.point(-1, -1)
          onPressed: Qt.quit()
          onWheel: Qt.quit()
          onPositionChanged: mouse => {
            if (root.armed && lastPosition.x >= 0
                && Math.abs(mouse.x - lastPosition.x) + Math.abs(mouse.y - lastPosition.y) > 5) {
              Qt.quit()
            }
            if (!root.armed || lastPosition.x < 0) lastPosition = Qt.point(mouse.x, mouse.y)
          }
        }
      }
    }
  }
}
