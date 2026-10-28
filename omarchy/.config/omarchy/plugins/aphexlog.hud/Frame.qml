import QtQuick

// Restrained HUD details: dual neon rails, corner brackets, and a fine grid.
Item {
  id: root
  property real pointerX: width / 2
  property bool bottomEdge: false
  clip: true
  opacity: 0.85
  Rectangle {
    anchors.fill: parent
    radius: 8
    color: "transparent"
    border.width: 1
    border.color: "#426b83"
  }
  Rectangle {
    x: 12; y: root.bottomEdge ? root.height - 2 : 0
    width: Math.max(0, root.width - 24); height: 2
    gradient: Gradient {
      orientation: Gradient.Horizontal
      GradientStop { position: 0; color: "#00e5ff" }
      GradientStop { position: 0.55; color: "#759dff" }
      GradientStop { position: 1; color: "#f072ff" }
    }
  }
  Repeater {
    model: 4
    Item {
      required property int index
      x: index % 2 ? root.width - 15 : 0
      y: index > 1 ? root.height - 15 : 0
      width: 15; height: 15
      Rectangle { width: 15; height: 2; y: index > 1 ? 13 : 0; color: index % 2 ? "#f072ff" : "#00e5ff" }
      Rectangle { width: 2; height: 15; x: index % 2 ? 13 : 0; color: index % 2 ? "#f072ff" : "#00e5ff" }
    }
  }
  Rectangle {
    x: Math.max(18, Math.min(root.pointerX - 3, root.width - 24))
    y: root.bottomEdge ? root.height - 4 : -2
    width: 6; height: 6; rotation: 45
    color: "#00e5ff"
  }
}
