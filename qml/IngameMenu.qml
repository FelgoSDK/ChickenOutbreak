import QtQuick 1.1

Column {
  spacing: 2
  anchors.centerIn: parent


  MenuButton {
    text: qsTr("Resume")
    onClicked: scene.state = "" // reset to default state, so hide this menu
  }

  MenuButton {
    text: qsTr("Restart")
    onClicked: {
      level.restartGame();
      scene.state = "" // reset to default state, so hide this menu
    }
  }
}
