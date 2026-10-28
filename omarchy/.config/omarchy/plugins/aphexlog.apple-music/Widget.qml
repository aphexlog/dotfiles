import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import qs.Commons
import qs.Ui
import "../aphexlog.hud" as Hud

Panel {
  id: root
  moduleName: "aphexlog.apple-music"
  ipcTarget: "aphexlog.apple-music"
  manageIpc: false
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  property bool showQueue: false
  function popupState() {
    return {open: panel.open, visible: panel.visible, screen: panel.screen ? panel.screen.name : "",
      width: panel.contentWidth, height: panel.contentHeight, toolbar: panel.toolbar, anchored: !!panel.anchorWindow}
  }

  Translations { id: strings; directory: Qt.resolvedUrl("i18n") }

  function formatTime(seconds) {
    var total = Math.max(0, Math.floor(seconds || 0))
    return I18n.formatNumber(Math.floor(total / 60)) + ":"
      + (total % 60 < 10 ? "0" : "") + I18n.formatNumber(total % 60)
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰀵"
    active: Music.playing
    tooltipText: "Apple Music"
    onPressed: function(mouseButton) {
      if (mouseButton === Qt.RightButton) Music.togglePlay()
      else root.toggle()
    }
    onWheelMoved: function(delta) {
      if (delta < 0) Music.nextTrack()
      else if (delta > 0) Music.previousTrack()
    }
  }

  component ControlButton: Button {
    foreground: Hud.Context.foreground
    accent: Hud.Context.magenta
    opacity: enabled ? 1 : 0.35
    focusable: true
    iconSize: Style.font.title
    horizontalPadding: Style.space(4)
    verticalPadding: Style.space(4)
  }

  Hud.KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(340))
    contentHeight: panel.fittedContentHeight(column.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      Keys.onSpacePressed: Music.togglePlay()

      Column {
        id: column
        width: parent.width
        spacing: Style.space(12)

        // Match the YouTube player's compact cover-and-track header.
        Item {
          width: parent.width
          height: cover.height
          Rectangle {
            id: cover
            width: Style.space(72)
            height: width
            radius: Style.cornerRadius
            color: "#172b42"
            clip: true
            PlainText {
              anchors.centerIn: parent
              visible: artwork.status !== Image.Ready
              text: "󰀵"
              color: Hud.Context.magenta
              font.pixelSize: Style.font.display
            }
            Image {
              id: artwork
              anchors.fill: parent
              source: root.opened ? Music.artwork : ""
              sourceSize.width: 160
              sourceSize.height: 160
              fillMode: Image.PreserveAspectCrop
              asynchronous: true
            }
          }
          Column {
            anchors.left: cover.right
            anchors.leftMargin: Style.space(14)
            anchors.right: expand.left
            anchors.rightMargin: Style.space(8)
            anchors.verticalCenter: cover.verticalCenter
            spacing: Style.space(3)
            PlainText { width: parent.width; text: "Apple Music"; color: Hud.Context.magenta; font.pixelSize: Style.font.caption }
            PlainText { width: parent.width; text: Music.title || strings.t("player.ready"); font.pixelSize: Style.font.title; font.bold: true }
            PlainText { width: parent.width; text: [Music.artist, Music.album].filter(function(value) { return value !== "" }).join(" · "); opacity: 0.7 }
          }
          ControlButton {
            id: closeButton
            anchors.top: parent.top
            anchors.right: parent.right
            iconText: "󰅖"
            tooltipText: strings.t("player.close")
            onClicked: root.close()
          }
          ControlButton {
            id: expand
            anchors.top: parent.top
            anchors.right: closeButton.left
            iconText: "󰊓"
            tooltipText: strings.t("player.open")
            onClicked: { root.close(); Music.openApp() }
          }
        }
        PlainText {
          width: parent.width
          visible: !Music.connected
          text: strings.t("player.empty")
          wrapMode: Text.Wrap
          opacity: 0.7
        }
        PlainText { width: parent.width; visible: Music.errorMessage !== ""; text: Music.errorMessage; wrapMode: Text.Wrap; color: "#ff789b" }

        Column {
          width: parent.width
          spacing: Style.space(2)
          visible: Music.connected && Music.length > 0
          PanelSlider {
            id: progress
            width: parent.width
            bar: root.bar
            fillColor: Hud.Context.magenta
            knobColor: Hud.Context.foreground
            height: Style.space(18)
            enabled: Music.canSeek
            opacity: enabled ? 1 : 0.5
            minimum: 0
            maximum: Math.max(1, Music.length)
            value: Math.min(Music.position, Music.length)
            step: 1
            onReleased: function(value) { Music.seekTo(value) }
          }
          Row {
            width: parent.width
            PlainText {
              width: parent.width / 2
              text: root.formatTime(progress.dragging ? progress.liveValue : Music.position)
              opacity: 0.6
            }
            PlainText {
              width: parent.width / 2
              text: root.formatTime(Music.length)
              horizontalAlignment: Text.AlignRight
              opacity: 0.6
            }
          }
        }

        Row {
          anchors.horizontalCenter: parent.horizontalCenter
          spacing: Style.space(18)
          ControlButton {
            anchors.verticalCenter: parent.verticalCenter
            iconText: "󰒟"
            tooltipText: strings.t("player.shuffle")
            enabled: Music.canShuffle
            selected: Music.shuffle
            onClicked: Music.toggleShuffle()
          }
          ControlButton {
            anchors.verticalCenter: parent.verticalCenter
            iconText: "󰒮"
            tooltipText: strings.t("player.previous")
            enabled: Music.canPrevious
            onClicked: Music.previousTrack()
          }
          ControlButton {
            iconText: Music.playing ? "󰏤" : "󰐊"
            tooltipText: strings.t(Music.playing ? "player.pause" : "player.play")
            anchors.verticalCenter: parent.verticalCenter
            iconSize: Style.font.display
            enabled: Music.canPlay
            onClicked: Music.togglePlay()
          }
          ControlButton {
            anchors.verticalCenter: parent.verticalCenter
            iconText: "󰒭"
            tooltipText: strings.t("player.next")
            enabled: Music.canNext
            onClicked: Music.nextTrack()
          }
          ControlButton {
            anchors.verticalCenter: parent.verticalCenter
            enabled: Music.canRepeat
            iconText: Music.repeat === "ONE" ? "󰑘" : "󰑖"
            selected: Music.repeat !== "NONE"
            tooltipText: strings.t("player.repeat")
            onClicked: Music.cycleRepeat()
          }
        }

        Item {
          width: parent.width
          height: Math.max(muteButton.height, volumeSlider.height)
          visible: Music.connected
          enabled: Music.hasVolume
          opacity: enabled ? 1 : 0.35
          ControlButton {
            id: muteButton
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            iconText: Music.volume === 0 ? "󰝟" : "󰕾"
            tooltipText: strings.t("player.volume")
            onClicked: Music.toggleMute()
          }
          PanelSlider {
            id: volumeSlider
            anchors.left: muteButton.right
            anchors.leftMargin: Style.space(8)
            anchors.right: volumeText.left
            anchors.rightMargin: Style.space(10)
            anchors.verticalCenter: parent.verticalCenter
            height: Style.space(18)
            bar: root.bar
            fillColor: Hud.Context.cyan
            minimum: 0
            maximum: 1
            step: 0.01
            value: Music.volume
            onReleased: function(value) { Music.setVolume(value) }
          }
          PlainText {
            id: volumeText
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: Style.space(36)
            horizontalAlignment: Text.AlignRight
            font.pixelSize: Style.font.caption
            opacity: 0.6
            text: Math.round((volumeSlider.dragging ? volumeSlider.liveValue : Music.volume) * 100) + "%"
          }
        }

        Item {
          width: parent.width
          height: queueButton.height
          ControlButton {
            id: queueButton
            anchors.left: parent.left
            iconText: "󰍜"
            selected: root.showQueue
            enabled: Music.queue.length > 0
            tooltipText: strings.t("player.queue")
            onClicked: root.showQueue = !root.showQueue
          }
          PlainText {
            anchors.centerIn: parent
            text: strings.t(Music.playing ? "player.playing" : Music.connected ? "player.paused" : "player.ready")
            color: Music.playing ? Hud.Context.cyan : Hud.Context.foreground
            opacity: 0.7
            font.pixelSize: Style.font.caption
          }
          ControlButton {
            anchors.right: parent.right
            iconText: "󰏌"
            tooltipText: strings.t("player.open")
            onClicked: { root.close(); Music.openApp() }
          }
        }
        ListView {
          width: parent.width
          height: Math.min(contentHeight, Style.space(180))
          visible: root.showQueue && Music.queue.length > 0
          model: Music.queue
          clip: true
          spacing: Style.space(5)
          delegate: PlainText {
            required property var modelData
            width: ListView.view.width
            text: modelData.title + " · " + modelData.artist
            font.pixelSize: Style.font.bodySmall
          }
        }
      }
    }
  }
}
