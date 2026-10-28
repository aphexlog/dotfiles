import QtQuick 2.0
import SddmComponents 2.0

// ==============================================================================
// Authentication — keep credentials and session startup inside SDDM
// ==============================================================================
Rectangle {
  id: root
  width: 1280
  height: 720
  color: "#060b13"

  property string currentUser: userModel.lastUser
  property bool loginFailed: false
  property bool authenticating: false
  property date currentTime: new Date()
  readonly property color neon: "#63f5ed"
  readonly property color magenta: "#f275cf"
  property int sessionIndex: {
    for (var i = 0; i < sessionModel.rowCount(); i++) {
      var name = (sessionModel.data(sessionModel.index(i, 0), Qt.DisplayRole) || "").toString()
      if (name.indexOf("uwsm") !== -1)
        return i
    }
    return sessionModel.lastIndex
  }

  Connections {
    target: sddm
    function onLoginFailed() {
      root.authenticating = false
      password.text = ""
      root.loginFailed = true
      password.forceActiveFocus()
    }
    function onLoginSucceeded() {
      root.loginFailed = false
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: root.currentTime = new Date()
  }

  // Quiet terminal grid, matching the existing cyber-pirate lock screen.
  Repeater {
    model: Math.ceil(root.width / 80)
    Rectangle {
      required property int index
      x: index * 80
      width: 1
      height: root.height
      color: "#0d1b27"
    }
  }
  Repeater {
    model: Math.ceil(root.height / 5)
    Rectangle {
      required property int index
      y: index * 5
      width: root.width
      height: 1
      color: index % 16 === 0 ? "#0d1b27" : "#090f19"
    }
  }

  Text {
    anchors { top: parent.top; left: parent.left; margins: 36 }
    text: "SOL / SECURE TERMINAL"
    color: root.neon
    font { family: "monospace"; pixelSize: 12; letterSpacing: 3 }
  }
  Text {
    anchors { top: parent.top; right: parent.right; margins: 36 }
    text: Qt.formatDateTime(root.currentTime, "ddd, dd MMM yyyy").toUpperCase()
    color: "#71909e"
    font { family: "monospace"; pixelSize: 12; letterSpacing: 2 }
  }

  // Scale the shared skull-and-terminal layout to landscape or portrait displays.
  Item {
    id: consolePanel
    anchors.centerIn: parent
    width: 1100
    height: 620
    scale: Math.max(0.1, Math.min(1.6, (root.width - 64) / width, (root.height - 140) / height))

    Image {
      anchors.verticalCenter: parent.verticalCenter
      width: 550
      height: 610
      source: "cyber-skull.svg"
      fillMode: Image.PreserveAspectFit
      sourceSize.width: Math.ceil(width * consolePanel.scale)
      sourceSize.height: Math.ceil(height * consolePanel.scale)
    }
    Rectangle {
      x: 577; y: 70
      width: 1; height: 480
      color: "#35565f"
    }
    Text {
      x: 635; y: 102
      text: Qt.formatDateTime(root.currentTime, "HH:mm")
      color: "#e0f8f6"
      font { family: "monospace"; pixelSize: 76; weight: Font.Light; letterSpacing: -4 }
    }
    Text {
      x: 640; y: 211
      text: "PRIVATE ACCESS"
      color: root.magenta
      font { family: "monospace"; pixelSize: 14; letterSpacing: 5 }
    }
    Text {
      x: 640; y: 249
      text: "IDENTITY  /  " + root.currentUser.toUpperCase()
      color: "#90aab7"
      font { family: "monospace"; pixelSize: 12; letterSpacing: 2 }
    }

    Rectangle {
      x: 635; y: 302
      width: 381; height: 67
      radius: 3
      color: "#0b1822"
      border { width: 1; color: root.loginFailed ? root.magenta : root.neon }

      Text {
        anchors.centerIn: parent
        visible: password.text.length === 0 && !root.authenticating
        text: "Enter access key"
        color: "#71909e"
        font { family: "monospace"; pixelSize: 20 }
      }
      TextInput {
        id: password
        anchors { fill: parent; margins: 18 }
        verticalAlignment: TextInput.AlignVCenter
        horizontalAlignment: TextInput.AlignHCenter
        echoMode: TextInput.Password
        passwordCharacter: "\u25cf"
        passwordMaskDelay: 0
        color: "#e0f8f6"
        selectionColor: "#35565f"
        font { family: "monospace"; pixelSize: 24 }
        clip: true
        readOnly: root.authenticating
        focus: true
        onTextChanged: root.loginFailed = false
        Keys.onPressed: function(event) {
          if (!root.authenticating && (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)) {
            root.authenticating = true
            sddm.login(root.currentUser, password.text, root.sessionIndex)
            event.accepted = true
          }
        }
      }
    }
    Text {
      x: 640; y: 390
      text: root.authenticating ? "AUTHENTICATING…" : root.loginFailed ? "ACCESS DENIED / RETRY" : "AWAITING CREDENTIALS"
      color: root.loginFailed ? root.magenta : "#71909e"
      font { family: "monospace"; pixelSize: 10; letterSpacing: 1 }
    }
    Rectangle { x: 640; y: 436; width: 32; height: 2; color: root.magenta }
  }

  Text {
    anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; bottomMargin: 30 }
    text: "[ ENTER ]  SIGN IN     /     SOL NETWORK · PRIVATE ACCESS"
    color: "#506b7c"
    font { family: "monospace"; pixelSize: 10; letterSpacing: 2 }
  }

  Component.onCompleted: password.forceActiveFocus()
}
