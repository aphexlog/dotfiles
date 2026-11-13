import QtQuick
import qs.Commons
import qs.Ui
import "../aphexlog.hud" as Hud

Panel {
  id: root
  moduleName: "aphexlog.cliamp"
  ipcTarget: "aphexlog.cliamp"
  manageIpc: false
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  readonly property color accent: "#ffc36a"
  Translations { id: strings; directory: Qt.resolvedUrl("i18n") }

  function popupState() {
    return {open: panel.open, visible: panel.visible, screen: panel.screen ? panel.screen.name : "",
      width: panel.contentWidth, height: panel.contentHeight, toolbar: panel.toolbar, anchored: !!panel.anchorWindow}
  }
  function formatTime(seconds) {
    var total = Math.max(0, Math.floor(seconds || 0))
    return I18n.formatNumber(Math.floor(total / 60)) + ":"
      + (total % 60 < 10 ? "0" : "") + I18n.formatNumber(total % 60)
  }

  // Keep the toolbar gestures consistent with the adjacent music players.
  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: ""
    active: Player.playing
    tooltipText: "Cliamp"
    onPressed: function(mouseButton) {
      if (mouseButton === Qt.RightButton) Player.togglePlay()
      else if (mouseButton === Qt.MiddleButton) Player.openApp()
      else root.toggle()
    }
    onWheelMoved: function(delta) {
      if (delta < 0) Player.nextTrack()
      else if (delta > 0) Player.previousTrack()
    }
  }

  component ControlButton: Button {
    foreground: Hud.Context.foreground
    accent: root.accent
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
      Keys.onSpacePressed: Player.togglePlay()

      Column {
        id: column
        width: parent.width
        spacing: Style.space(12)

        // The packaged app icon stays local; track metadata is always plain text.
        Item {
          width: parent.width
          height: cover.height
          Rectangle {
            id: cover
            width: Style.space(64)
            height: width
            radius: Style.cornerRadius
            color: "#172b42"
            PlainText {
              anchors.centerIn: parent
              visible: appIcon.status !== Image.Ready
              text: ""
              color: root.accent
              font.pixelSize: Style.font.display
            }
            Image {
              id: appIcon
              anchors.fill: parent
              anchors.margins: Style.space(6)
              source: "file:///usr/share/icons/hicolor/512x512/apps/cliamp.png"
              sourceSize.width: 128
              sourceSize.height: 128
              fillMode: Image.PreserveAspectFit
            }
          }
          Column {
            anchors.left: cover.right
            anchors.leftMargin: Style.space(14)
            anchors.right: closeButton.left
            anchors.rightMargin: Style.space(8)
            anchors.verticalCenter: cover.verticalCenter
            spacing: Style.space(3)
            PlainText { width: parent.width; text: "Cliamp"; color: root.accent; font.pixelSize: Style.font.caption }
            PlainText { width: parent.width; text: Player.title || strings.t("player.ready"); font.pixelSize: Style.font.title; font.bold: true }
            PlainText {
              width: parent.width
              text: [Player.artist, Player.album].filter(function(value) { return value !== "" }).join(" · ")
              opacity: 0.7
            }
          }
          ControlButton {
            id: closeButton
            anchors.top: parent.top
            anchors.right: parent.right
            iconText: "󰅖"
            tooltipText: strings.t("player.close")
            onClicked: root.close()
          }
        }
        PlainText {
          width: parent.width
          visible: !Player.connected
          text: strings.t("player.empty")
          wrapMode: Text.Wrap
          opacity: 0.7
        }

        // Seek only when Cliamp supplies a finite, seekable track duration.
        Column {
          width: parent.width
          spacing: Style.space(2)
          visible: Player.connected && Player.length > 0
          PanelSlider {
            id: progress
            width: parent.width
            height: Style.space(18)
            bar: root.bar
            fillColor: root.accent
            knobColor: Hud.Context.foreground
            enabled: Player.canSeek
            opacity: enabled ? 1 : 0.5
            minimum: 0
            maximum: Math.max(1, Player.length)
            value: Math.min(Player.position, Player.length)
            step: 1
            onReleased: function(value) { Player.seekTo(value) }
          }
          Row {
            width: parent.width
            PlainText {
              width: parent.width / 2
              text: root.formatTime(progress.dragging ? progress.liveValue : Player.position)
              opacity: 0.6
            }
            PlainText {
              width: parent.width / 2
              text: root.formatTime(Player.length)
              horizontalAlignment: Text.AlignRight
              opacity: 0.6
            }
          }
        }

        Row {
          anchors.horizontalCenter: parent.horizontalCenter
          spacing: Style.space(24)
          ControlButton {
            anchors.verticalCenter: parent.verticalCenter
            iconText: "󰒮"
            tooltipText: strings.t("player.previous")
            enabled: Player.canPrevious
            onClicked: Player.previousTrack()
          }
          ControlButton {
            anchors.verticalCenter: parent.verticalCenter
            iconText: Player.playing ? "󰏤" : "󰐊"
            tooltipText: strings.t(Player.playing ? "player.pause" : "player.play")
            iconSize: Style.font.display
            enabled: Player.canPlay
            onClicked: Player.togglePlay()
          }
          ControlButton {
            anchors.verticalCenter: parent.verticalCenter
            iconText: "󰒭"
            tooltipText: strings.t("player.next")
            enabled: Player.canNext
            onClicked: Player.nextTrack()
          }
        }

        Item {
          width: parent.width
          height: Math.max(muteButton.height, volumeSlider.height)
          visible: Player.hasVolume
          ControlButton {
            id: muteButton
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            iconText: Player.volume === 0 ? "󰝟" : "󰕾"
            tooltipText: strings.t("player.volume")
            onClicked: Player.toggleMute()
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
            value: Player.volume
            onReleased: function(value) { Player.setVolume(value) }
          }
          PlainText {
            id: volumeText
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: Style.space(40)
            horizontalAlignment: Text.AlignRight
            font.pixelSize: Style.font.caption
            opacity: 0.6
            text: I18n.formatNumber(Math.round((volumeSlider.dragging ? volumeSlider.liveValue : Player.volume) * 100)) + "%"
          }
        }

        Item {
          width: parent.width
          height: openButton.height
          PlainText {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: strings.t("player." + Player.state)
            color: Player.playing ? root.accent : Hud.Context.foreground
            opacity: 0.7
          }
          ControlButton {
            id: openButton
            anchors.right: parent.right
            iconText: "󰆍"
            text: strings.t("player.open")
            tooltipText: strings.t("player.open")
            onClicked: { root.close(); Player.openApp() }
          }
        }
      }
    }
  }
}
