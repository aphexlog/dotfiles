import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Ui as Ui
import qs.Commons as Commons
import "../aphexlog.hud" as Hud

Ui.BarWidget {
  id: root
  moduleName: "aphexlog.controls"
  property bool opened: false
  property var desktop: ({monitors: [], workspaces: [], windows: [], scales: []})
  property string selectedWindow: ""
  property string errorMessage: ""
  property bool closeOnSuccess: false
  readonly property string backend: Quickshell.env("HOME") + "/.local/bin/cyber-desktop"
  readonly property string family: "JetBrainsMono Nerd Font"
  Commons.Translations { id: strings; directory: Qt.resolvedUrl("i18n") }

  function refresh() {
    if (!reader.running) reader.running = true
  }
  function open() { selectedWindow = ""; refresh(); opened = true }
  function openFromBar(position) { open() }
  function close() { opened = false }
  function toggle() { opened ? close() : open() }
  function act(request, dismiss) {
    if (writer.running) return
    errorMessage = ""
    closeOnSuccess = dismiss === true
    writer.command = ["python3", backend, JSON.stringify(request)]
    writer.running = true
  }
  function windowAction(action, extra, dismiss) {
    if (!selectedWindow) return
    act(Object.assign({action: action, window: selectedWindow}, extra || {}), dismiss)
  }
  function visibleWorkspace(id) {
    return desktop.monitors.some(function(m) { return m.activeWorkspace.id === id })
  }

  implicitWidth: icon.implicitWidth
  implicitHeight: icon.implicitHeight
  Ui.WidgetButton {
    id: icon
    anchors.fill: parent
    bar: root.bar
    text: "󰒓"
    onPressed: root.toggle()
  }

  Process {
    id: reader
    command: ["python3", root.backend, "status"]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          var result = JSON.parse(text)
          if (!result.ok) { root.errorMessage = result.error; return }
          root.desktop = result
          if (!result.windows.some(function(w) { return w.address === root.selectedWindow }))
            root.selectedWindow = result.activeWindow || (result.windows[0] ? result.windows[0].address : "")
        } catch (_) { root.errorMessage = strings.t("readError") }
      }
    }
  }
  Process {
    id: writer
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          var result = JSON.parse(text)
          if (!result.ok) root.errorMessage = result.error
          else {
            if (root.closeOnSuccess) root.close()
            root.refresh()
          }
        } catch (_) { root.errorMessage = strings.t("actionError") }
      }
    }
  }
  Timer {
    interval: 2000
    running: root.opened
    repeat: true
    onTriggered: if (!writer.running) root.refresh()
  }

  component Label: Text {
    textFormat: Text.PlainText
    color: Hud.Context.foreground
    font.family: root.family
    font.pixelSize: 13
    elide: Text.ElideRight
  }
  component Section: Label {
    color: Hud.Context.cyan
    font.pixelSize: 12
    font.bold: true
    topPadding: 7
  }
  component Action: Ui.Button {
    focusable: true
    bordered: true
    foreground: Hud.Context.foreground
    accent: Hud.Context.cyan
    background: "#111d32"
    fontFamily: root.family
    fontSize: 13
    horizontalPadding: 10
    verticalPadding: 7
    enabled: !writer.running
    Layout.fillWidth: true
  }

  Hud.KeyboardPanel {
    id: popup
    anchorItem: icon
    bar: root.bar
    owner: root
    open: root.opened
    focusTarget: keyboard
    contentWidth: fittedContentWidth(640)
    contentHeight: fittedContentHeight(column.implicitHeight)

    FocusScope {
      id: keyboard
      anchors.fill: parent
      Keys.onEscapePressed: root.close()
      Flickable {
        anchors.fill: parent
        clip: true
        contentHeight: column.implicitHeight
        boundsBehavior: Flickable.StopAtBounds
        ColumnLayout {
          id: column
          width: parent.width
          spacing: 8

          RowLayout {
            Layout.fillWidth: true
            Label { text: strings.t("title"); font.pixelSize: 22; font.bold: true; Layout.fillWidth: true }
            Action { text: "×"; Layout.fillWidth: false; onClicked: root.close() }
          }
          Label { text: strings.t("subtitle"); color: Hud.Context.magenta }
          Label {
            visible: root.errorMessage !== ""
            text: root.errorMessage
            color: "#ff789b"
            wrapMode: Text.Wrap
            elide: Text.ElideNone
            Layout.fillWidth: true
          }

          Section { text: strings.t("workspaces") }
          Repeater {
            model: [{label: "left", first: 1}, {label: "right", first: 6}]
            delegate: RowLayout {
              id: workspaceRow
              required property var modelData
              Layout.fillWidth: true
              Label { text: strings.t(workspaceRow.modelData.label); Layout.preferredWidth: 80 }
              Repeater {
                model: 5
                delegate: Action {
                  required property int index
                  readonly property int workspaceId: workspaceRow.modelData.first + index
                  text: String(workspaceId % 10)
                  selected: root.visibleWorkspace(workspaceId)
                  tooltipText: strings.t("workspaceHelp")
                  onClicked: root.act({action: "focus_workspace", workspace: workspaceId}, true)
                  onRightClicked: root.windowAction("move_window", {workspace: workspaceId})
                }
              }
            }
          }
          Label { text: strings.t("workspaceHelp"); font.pixelSize: 11; color: "#85b5ca" }

          Section { text: strings.t("windows") }
          ListView {
            id: windowList
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(3, Math.max(1, count)) * 35
            model: root.desktop.windows
            clip: true
            spacing: 3
            delegate: Action {
              required property var modelData
              width: windowList.width
              height: 32
              text: modelData.workspace.name + " · " + modelData.class + " · " + modelData.title
              leftAlign: true
              selected: modelData.address === root.selectedWindow
              onClicked: root.selectedWindow = modelData.address
            }
            Label { visible: windowList.count === 0; text: strings.t("noWindows") }
          }
          ColumnLayout {
            Layout.fillWidth: true
            enabled: root.selectedWindow !== ""
            opacity: enabled ? 1 : 0.45
            RowLayout {
              Layout.fillWidth: true
              Action { text: strings.t("focus"); onClicked: root.windowAction("focus_window", {}, true) }
              Action { text: strings.t("sendLeft"); onClicked: root.windowAction("move_window", {monitor: "left"}) }
              Action { text: strings.t("sendRight"); onClicked: root.windowAction("move_window", {monitor: "right"}) }
            }
            RowLayout {
              Layout.fillWidth: true
              Repeater {
                model: ["float", "tile", "center", "fullscreen", "maximize"]
                delegate: Action {
                  required property string modelData
                  text: strings.t(modelData)
                  onClicked: root.windowAction(modelData + "_window", {}, modelData === "fullscreen")
                }
              }
            }
            RowLayout {
              Layout.fillWidth: true
              Repeater {
                model: [{label: "widthLess", x: -100, y: 0}, {label: "widthMore", x: 100, y: 0},
                  {label: "heightLess", x: 0, y: -100}, {label: "heightMore", x: 0, y: 100}]
                delegate: Action {
                  required property var modelData
                  text: strings.t(modelData.label)
                  onClicked: root.windowAction("resize_window", {x: modelData.x, y: modelData.y})
                }
              }
            }
          }

          Section { text: strings.t("displays") }
          Repeater {
            model: root.desktop.monitors
            delegate: RowLayout {
              id: displayRow
              required property var modelData
              required property int index
              Layout.fillWidth: true
              Label {
                text: strings.t(displayRow.index === 0 ? "left" : "right")
                Layout.preferredWidth: 80
              }
              Repeater {
                model: root.desktop.scales
                delegate: Action {
                  required property real modelData
                  text: Math.round(modelData * 100) + "%"
                  selected: Math.abs(displayRow.modelData.scale - modelData) < 0.001
                  enabled: !writer.running
                    && Math.abs(displayRow.modelData.width / modelData - Math.round(displayRow.modelData.width / modelData)) < 0.001
                    && Math.abs(displayRow.modelData.height / modelData - Math.round(displayRow.modelData.height / modelData)) < 0.001
                  opacity: enabled ? 1 : 0.35
                  onClicked: root.act({action: "monitor_scale", monitor: displayRow.modelData.name, value: modelData})
                }
              }
            }
          }

          Section { text: strings.t("settings") }
          GridLayout {
            Layout.fillWidth: true
            columns: 3
            Repeater {
              model: ["audio", "network", "bluetooth", "wallpaper", "theme", "keybindings"]
              delegate: Action {
                required property string modelData
                text: strings.t(modelData)
                onClicked: root.act({action: "settings", setting: modelData}, true)
              }
            }
          }
          RowLayout {
            Layout.fillWidth: true
            Action { text: strings.t("nightlight"); onClicked: root.act({action: "toggle", setting: "nightlight"}) }
            Action { text: strings.t("idle"); onClicked: root.act({action: "toggle", setting: "idle"}) }
            Action { text: strings.t("mute"); onClicked: root.act({action: "mute"}) }
            Action { text: strings.t("microphone"); onClicked: root.act({action: "microphone_mute"}) }
          }
          Label {
            text: strings.t("help")
            color: "#85b5ca"
            font.pixelSize: 11
            wrapMode: Text.Wrap
            elide: Text.ElideNone
            Layout.fillWidth: true
          }
        }
      }
    }
  }
}
