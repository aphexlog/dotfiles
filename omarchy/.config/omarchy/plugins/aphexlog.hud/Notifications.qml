import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui
import "." as Hud

Panel {
  id: root
  moduleName: "aphexlog.hud"
  property var entries: []
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight
  onOpenedChanged: if (opened) reader.running = true
  WidgetButton {
    id: button
    bar: root.bar
    text: "󰂚"
    onPressed: root.toggle()
  }
  Process {
    id: reader
    command: ["python3", Quickshell.env("HOME") + "/.local/bin/cyber-bar-notifications"]
    stdout: StdioCollector {
      onStreamFinished: {
        try { root.entries = JSON.parse(text) } catch (_) { root.entries = [] }
      }
    }
  }
  Hud.KeyboardPanel {
    id: popup
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keys
    padding: 24
    contentWidth: fittedContentWidth(440)
    contentHeight: Math.min(600, Math.max(180, list.contentHeight + 110), availableCardHeight)
    Item {
      id: keys
      anchors.fill: parent
      Keys.onEscapePressed: root.close()
      Text {
        id: title
        text: "N O T I F I C A T I O N S  /  " + root.entries.length
        color: "#00e5ff"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 13
      }
      Text {
        anchors.right: parent.right
        text: "×"
        color: "#f072ff"
        font.pixelSize: 22
        MouseArea { anchors.fill: parent; onClicked: root.close(); cursorShape: Qt.PointingHandCursor }
      }
      ListView {
        id: list
        anchors { top: title.bottom; topMargin: 22; bottom: parent.bottom; left: parent.left; right: parent.right }
        clip: true
        spacing: 10
        model: root.entries
        delegate: Rectangle {
          required property var modelData
          width: list.width
          height: contents.implicitHeight + 24
          radius: 5
          color: "#111d32"
          border.width: 1
          border.color: "#25485e"
          Column {
            id: contents
            x: 12; y: 12; width: parent.width - 24
            spacing: 8
            Text {
              width: parent.width
              text: (modelData.app || "System").toUpperCase()
              color: "#f072ff"
              font.family: "JetBrainsMono Nerd Font"
              font.pixelSize: 10
              elide: Text.ElideRight
            }
            Text {
              width: parent.width
              text: modelData.summary || "Notification"
              textFormat: Text.PlainText
              color: "#d8f7ff"
              font.pixelSize: 14
              font.bold: true
              wrapMode: Text.Wrap
            }
            Text {
              width: parent.width
              visible: text !== ""
              text: modelData.body || ""
              textFormat: Text.PlainText
              color: "#9bafc7"
              font.pixelSize: 12
              wrapMode: Text.Wrap
              maximumLineCount: 5
              elide: Text.ElideRight
            }
          }
        }
        Text {
          visible: root.entries.length === 0
          text: "All clear. No recent notifications."
          color: "#9bafc7"
          font.pixelSize: 13
        }
      }
    }
  }
}
