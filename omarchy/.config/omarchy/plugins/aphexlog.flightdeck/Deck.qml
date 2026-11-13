import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Ui as Ui
import qs.Commons as Commons
import "../aphexlog.hud" as Hud

Ui.BarWidget {
  id: root
  moduleName: "aphexlog.flightdeck"
  property bool opened: false
  property var session: ({state: "idle", minutes: 25, label: ""})
  property string errorMessage: ""
  property int selectedMinutes: 25
  property double now: Date.now() / 1000
  readonly property string backend: Quickshell.env("HOME") + "/.local/bin/cyber-flightdeck"
  readonly property int remaining: session.state === "running" ? Math.max(0, Math.ceil(session.end - now)) : 0
  readonly property bool ticking: session.state === "running" && remaining > 0
  readonly property bool complete: session.state === "done" || (session.state === "running" && remaining === 0)
  readonly property real progress: session.state === "idle" ? 0 : Math.max(0, Math.min(1, 1 - remaining / (session.minutes * 60)))
  readonly property color accent: ticking ? "#ffc36a" : complete ? "#68f0ba" : Hud.Context.cyan
  Commons.Translations { id: strings; directory: Qt.resolvedUrl("i18n") }

  // ==============================================================================
  // Shared Focus Session
  // ==============================================================================

  function refresh() { if (!reader.running && !writer.running) reader.running = true }
  function open() { now = Date.now() / 1000; errorMessage = ""; refresh(); opened = true }
  function openFromBar(position) { open() }
  function close() { opened = false }
  function toggle() { opened ? close() : open() }
  function act(request) {
    if (writer.running) return
    errorMessage = ""
    writer.command = ["python3", backend, JSON.stringify(request)]
    writer.running = true
  }
  function acceptState(data) {
    if (!data.ok) { errorMessage = data.error; return }
    session = data.timer
    now = Date.now() / 1000
    if (session.state !== "idle" && !task.activeFocus) task.text = session.label
    if (session.state !== "idle") selectedMinutes = session.minutes
  }
  function clock(seconds) {
    var total = Math.max(0, Math.ceil(seconds))
    return (total < 600 ? "0" : "") + Commons.I18n.formatNumber(Math.floor(total / 60))
      + ":" + (total % 60 < 10 ? "0" : "") + Commons.I18n.formatNumber(total % 60)
  }
  function popupState() {
    return {open: opened, screen: popup.screen ? popup.screen.name : "", toolbar: popup.toolbar,
      x: popup.cardOrigin.x, y: popup.cardOrigin.y, width: popup.contentWidth, height: popup.contentHeight,
      timer: session.state, remaining: remaining, artworkReady: emblem.status === Image.Ready}
  }

  implicitWidth: icon.implicitWidth
  implicitHeight: icon.implicitHeight
  Ui.WidgetButton { id: icon; anchors.fill: parent; bar: root.bar; text: "󰔛"; onPressed: root.toggle() }
  Process {
    id: reader
    command: ["python3", root.backend, "status"]
    stdout: StdioCollector {
      onStreamFinished: {
        try { root.acceptState(JSON.parse(text)) }
        catch (_) { root.errorMessage = strings.t("readError") }
      }
    }
  }
  Process {
    id: writer
    stdout: StdioCollector {
      onStreamFinished: {
        try { root.acceptState(JSON.parse(text)) }
        catch (_) { root.errorMessage = strings.t("actionError") }
      }
    }
    onExited: if (root.opened) root.refresh()
  }
  Timer { interval: 2000; running: root.opened; repeat: true; onTriggered: root.refresh() }
  Timer { interval: 1000; running: root.opened && root.ticking; repeat: true; onTriggered: root.now = Date.now() / 1000 }

  // ==============================================================================
  // Compact Focus Card
  // ==============================================================================

  component Action: Ui.Button {
    focusable: true
    bordered: true
    foreground: Hud.Context.foreground
    accent: root.accent
    background: "transparent"
    radius: 4
    fontFamily: "JetBrainsMono Nerd Font"
    fontSize: 12
    horizontalPadding: 10
    verticalPadding: 8
    Accessible.role: Accessible.Button
    Accessible.name: tooltipText !== "" ? tooltipText : text
    enabled: !writer.running
    opacity: enabled ? 1 : 0.4
  }

  Hud.KeyboardPanel {
    id: popup
    anchorItem: icon
    bar: root.bar
    owner: root
    open: root.opened
    focusTarget: keyboard
    padding: 20
    contentWidth: fittedContentWidth(380)
    contentHeight: fittedContentHeight(column.implicitHeight)

    FocusScope {
      id: keyboard
      anchors.fill: parent
      Keys.onEscapePressed: root.close()
      Flickable {
        anchors.fill: parent
        contentHeight: column.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        ColumnLayout {
          id: column
          width: parent.width
          spacing: 16
          Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 112
            RowLayout {
              anchors.fill: parent
              spacing: 16
              Emblem {
                id: emblem
                Layout.preferredWidth: 100
                Layout.preferredHeight: 108
              }
              ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                RowLayout {
                  spacing: 7
                  Rectangle { width: 5; height: 5; radius: 3; color: root.accent }
                  PlainText {
                    text: root.complete ? strings.t("complete") : strings.t("mode." + root.selectedMinutes)
                    color: "#92b5c7"
                    font.pixelSize: 11
                  }
                }
                PlainText {
                  Layout.fillWidth: true
                  text: root.clock(root.ticking ? root.remaining : root.complete ? 0 : root.selectedMinutes * 60)
                  font.pixelSize: 52
                  font.letterSpacing: -2
                  font.bold: true
                  fontSizeMode: Text.HorizontalFit
                  minimumPixelSize: 32
                  color: Hud.Context.foreground
                }
              }
            }
            Action {
              anchors.top: parent.top
              anchors.right: parent.right
              width: 24; height: 24
              text: "×"
              fontSize: 16
              bordered: false
              foreground: "#7391a5"
              tooltipText: strings.t("close")
              verticalPadding: 0; horizontalPadding: 0
              onClicked: root.close()
            }
          }
          Rectangle {
            Layout.fillWidth: true
            height: 2
            color: "#182b3b"
            Rectangle { width: parent.width * root.progress; height: parent.height; color: root.accent }
          }
          Controls.TextField {
            id: task
            Layout.fillWidth: true
            placeholderText: strings.t("taskPlaceholder")
            placeholderTextColor: "#7391a5"
            color: Hud.Context.foreground
            selectionColor: "#25485e"
            selectedTextColor: Hud.Context.foreground
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
            maximumLength: 100
            readOnly: root.ticking
            selectByMouse: true
            Accessible.name: strings.t("taskPlaceholder")
            padding: 12
            background: Rectangle { color: "#0b1523"; radius: 4; border.width: 1; border.color: task.activeFocus ? root.accent : "#1b3041" }
            onAccepted: if (!root.ticking) root.act({action: "start", minutes: root.selectedMinutes, label: text})
          }
          RowLayout {
            Layout.fillWidth: true
            spacing: 6
            Repeater {
              model: [25, 50, 5]
              delegate: Action {
                required property int modelData
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                Layout.preferredHeight: 40
                text: strings.t("preset." + modelData)
                tooltipText: strings.t("presetHint." + modelData)
                selected: root.selectedMinutes === modelData
                bordered: false
                enabled: !root.ticking && !writer.running
                opacity: enabled || root.selectedMinutes === modelData ? 1 : 0.4
                onClicked: root.selectedMinutes = modelData
              }
            }
            Action {
              visible: root.complete
              Layout.preferredWidth: 32
              Layout.preferredHeight: 40
              iconText: "󰑓"
              iconSize: 19
              tooltipText: strings.t("clear")
              bordered: false
              horizontalPadding: 0
              onClicked: root.act({action: "reset"})
            }
            Action {
              Layout.preferredWidth: 52
              Layout.preferredHeight: 40
              iconText: root.ticking ? "󰓛" : "󰐊"
              iconSize: 24
              tooltipText: root.ticking ? strings.t("end") : strings.t("start")
              foreground: root.accent
              background: root.ticking ? "#272017" : "#102c38"
              onClicked: root.act(root.ticking ? {action: "reset"} : {action: "start", minutes: root.selectedMinutes, label: task.text})
            }
          }
          PlainText { visible: root.errorMessage !== ""; text: root.errorMessage; color: "#ff789b"; wrapMode: Text.Wrap; Layout.fillWidth: true }
        }
      }
    }
  }
}
