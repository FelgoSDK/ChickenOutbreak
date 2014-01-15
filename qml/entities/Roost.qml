import QtQuick 1.1
import VPlay 1.0
import Box2D 1.0 // needed for Body.Static

EntityBase {
  entityType: "roost"

  poolingEnabled: true

  // put them before the windows
  z:1

  Component.onCompleted: console.debug("Roost.onCompleted()")
  Component.onDestruction: console.debug("Roost.onDestruction()")

  Image {
    id: sprite
    source: "../img/roost_higher.png"

    width: level.gridSize
    height: 8

    anchors.centerIn: parent
  }

  BoxCollider {
    id: collider
    bodyType: Body.Static

    anchors.fill: sprite
  }
}
