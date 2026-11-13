import QtQuick

// PHX frame: fine perimeter, short signal rails, and asymmetric corner marks.
Item {
  id: root
  property real pointerX: width / 2
  property bool bottomEdge: false
  clip: true
  opacity: 0.9
  Rectangle {
    anchors.fill: parent
    radius: 6
    color: "transparent"
    border.width: 1
    border.color: "#254253"
  }
  Rectangle {
    x: 12; y: root.bottomEdge ? root.height - 1 : 0
    width: Math.max(0, Math.min(140, root.width * 0.3)); height: 1
    gradient: Gradient {
      orientation: Gradient.Horizontal
      GradientStop { position: 0; color: Context.cyan }
      GradientStop { position: 1; color: "#254253" }
    }
  }
  Rectangle {
    x: root.width - width - 12; y: root.bottomEdge ? root.height - 1 : 0
    width: Math.min(44, root.width * 0.12); height: 1
    color: Context.magenta
  }
  Repeater {
    model: 4
    Item {
      required property int index
      x: index % 2 ? root.width - 10 : 0
      y: index > 1 ? root.height - 10 : 0
      width: 10; height: 10
      opacity: index === 0 || index === 3 ? 1 : 0.35
      Rectangle { width: 10; height: 1; y: index > 1 ? 9 : 0; color: index % 2 ? Context.magenta : Context.cyan }
      Rectangle { width: 1; height: 10; x: index % 2 ? 9 : 0; color: index % 2 ? Context.magenta : Context.cyan }
    }
  }
  Rectangle {
    x: Math.max(18, Math.min(root.pointerX - 3, root.width - 24))
    y: root.bottomEdge ? root.height - 2 : -2
    width: 4; height: 4; rotation: 45
    color: Context.cyan
  }
}
