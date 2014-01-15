import QtQuick 1.1
import VPlay 1.0

// is shown at game start and shows the maximum highscore and a button for starting the game
SceneBase {

  onBackPressed: {
    window.state = "main"
  }

  // this allows navigation through key presses
  Keys.onReturnPressed: {
    window.state = "main"
  }

  MultiResolutionImage {
    source: "img/mainMenuBackground-sd.png"
    anchors.centerIn: parent
  }

  Column {
    anchors.horizontalCenter: parent.horizontalCenter
    y: 50

    MenuText {
      text: qsTr("Credits")
      font.pixelSize: 35
    }

    Item {
      width: 1
      height: 35
    }

    MenuText {
      text: qsTr("Design:")
    }

    MenuText {
      text: "Astrid Handlechner"
    }

    Item {
      width: 1
      height: 25
    }

    MenuText {
      text: qsTr("Sound:")
    }

    MenuText {
      text: "\"Two Fat Gangsters\""
    }

    MenuText {
      text: "(playonloop.com)"
    }

    Item {
      width: 1
      height: 90
    }

    MenuText {
      text: qsTr("Proudly developed with")
    }

    MenuText {
      text: "V-Play Game Engine"
    }

  }

  MenuButton {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 30

    text: "Back"

    width: 170 * 0.8
    height: 60 * 0.8

    onClicked: window.state = "main"
  }
}
