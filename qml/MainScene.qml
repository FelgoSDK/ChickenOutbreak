import QtQuick 1.1
import VPlay 1.0

// is shown at game start and shows the maximum highscore and a button for starting the game
SceneBase {
  id: mainScene

  onBackPressed: {
    // instead of immediately shutting down the app, ask the user if he really wants to exit the app with a native dialog
    nativeUtils.displayMessageBox(qsTr("Really quit the game?"), "", 2);
  }

  Connections {
    // nativeUtils should only be connected, when this is the active scene
      target: activeScene === mainScene ? nativeUtils : null
      onMessageBoxFinished: {
        console.debug("the user confirmed the Ok/Cancel dialog with:", accepted)
        if(accepted)
          Qt.quit()
      }
  }

  MultiResolutionImage {
    source: "img/mainMenuBackground-sd.png"
    anchors.centerIn: parent
  }

  Column {
    spacing: 25
    anchors.horizontalCenter: parent.horizontalCenter
    y: 30

    MenuText {
      text: qsTr("Chicken Outbreak")
      font.pixelSize: 35
    }

    MenuText {
      text: qsTr("Highscore: ") + maximumHighscore
    }

    Item {
      width: 1
      height: 0
    }

    MenuButton {
      text: qsTr("Play")
      onClicked: window.state = "game"
      textSize: 30
    }

    Item {
      width: 1
      height: 75
    }

    MenuButton {
      text: qsTr("Highscores")

      width: 170 * 0.8
      height: 60 * 0.8

      // this button opens the gamecenter leaderboards - only show it if the gamecenter is available (so iOS only)
      visible: gameCenter.authenticated

      onClicked: gameCenter.showLeaderboard();
    }

    MenuButton {
      text: qsTr("Credits")

      width: 170 * 0.8
      height: 60 * 0.8

      onClicked: window.state = "credits";
    }

    MenuButton {
      text: settings.soundEnabled ? qsTr("Sound on") : qsTr("Sound off")

      width: 170 * 0.8
      height: 60 * 0.8

      onClicked: settings.soundEnabled = !settings.soundEnabled


      // this button should only be displayed on Symbian & Meego, because on the other platforms the volume hardware keys work; but on Sym & Meego the volume cant be adjusted as the hardware volume keys are not working
      // also, display it when in debug build for quick toggling the sound
      visible: system.debugBuild || system.isPlatform(System.Meego) || system.isPlatform(System.Symbian)
    }
  }

  // this allows navigation through key presses
  Keys.onReturnPressed: {
    window.state = "game"
  }
}
