import QtQuick 1.1
import VPlay 1.0

// base component for all 3 scenes in the game: MainScene, ChickenOutbreakScene and GameOverScene
Scene {
  id: sceneBase
  width: 320
  height: 480

  // this is an important performance improvement, as renderer can skip invisible items (and all its children)
  // also, the focus-property for key handling relies on the visible-property
  visible: opacity>0


  // handle this signal in each Scene
  signal backPressed

  // this fades in and out automatically, when the opacity gets changed from 0 to 1 in ChickenOutbreakMain
  Behavior on opacity {
    // the cross-fade animation should last 350ms
    NumberAnimation { duration: 350 }
  }

  Keys.onPressed: {
    console.debug("SceneBase: pressed key code: ", event.key)

    // only simulate on desktop platforms!
    if(event.key === Qt.Key_Backspace && system.desktopPlatform) {
      console.debug("backspace key pressed - simulate a back key pressed on desktop platforms for debugging the user flow of Android on windows!")
      backPressed()
    }
  }

  Keys.onBackPressed: {
    // handles the Android back button
    backPressed()
  }

}
