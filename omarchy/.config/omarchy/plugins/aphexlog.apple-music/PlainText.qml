import QtQuick
import qs.Commons
import "../aphexlog.hud" as Hud

Text {
  textFormat: Text.PlainText
  color: Hud.Context.foreground
  font.family: Style.font.family
  font.pixelSize: Style.font.bodySmall
  elide: Text.ElideRight
}
