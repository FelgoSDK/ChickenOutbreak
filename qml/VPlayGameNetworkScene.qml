import QtQuick 2.0
import VPlay 2.0

SceneBase {
  id: scene

  // needs to be accessed assigned to the VPlayGameNetwork, so it can show it
  property alias gameNetworkView: gameNetworkView

  onBackButtonPressed: {
    window.state = "main"
  }

  VPlayGameNetworkView {
    id: gameNetworkView
    anchors.fill: scene.gameWindowAnchorItem    

    // this is only used temporarily, until the font issue is fixed

    onBackClicked: {
      window.state = "main"
    }
  }
}
