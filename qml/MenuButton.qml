import QtQuick 1.1
import VPlay 1.0

// gets used for the Play button in MainScene and for the Continue button in GameOverScene
Image {
  id: button

  // width & height must get set from outside, these are the default values!
  width: 170
  height: 60
  source: "img/button.png"

  anchors.horizontalCenter: parent.horizontalCenter

  property alias text: buttonText.text
  property alias textColor: buttonText.color
  property alias textSize: buttonText.font.pixelSize
  property alias textItem: buttonText
  property alias font: buttonText.font

  signal clicked

  Text {
    id: buttonText
    anchors.centerIn: parent
    font.pixelSize: 22
    color: "#ca840a"

    font.family: fontHUD.name
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    onClicked: button.clicked()
  }
}
