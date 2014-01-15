import QtQuick 1.1
import VPlay 1.0

// gets displayed when the game is lost, and shows the reached score and if there was a new highscore reached
SceneBase {

  onBackPressed: {
    window.state = "main"
  }

  // this allows faster navigation through the scenes by pressing the Enter(=Return) key
  Keys.onReturnPressed: {
    window.state = "main"
  }

  // 3 different formats of the image are provided (-sd, -hd and -hd2)
  BackgroundImage {
    source: "img/gameOverScreen-sd.png"
    anchors.centerIn: parent
  }

  Image {
    // position manually so it is in the center of the egg
    x: 40
    y: 120
    scale: 0.3
    source: "img/chicken-dead01.png"
  }


  MenuText {
    y: 40
    text: qsTr("Game Over")
    font.pixelSize: 35
  }

  MenuText {
    id: scoreText
    y: 300
    text: "Your score: " + lastScore
  }

  MenuText {
    id: newMaximumHighscore
    text: qsTr("New highscore!!!")
    font.pixelSize: 14
    color: "#8f2727"
    visible: true
    anchors.top: scoreText.bottom
    anchors.topMargin: 10
    //visible: false gets set in enterScene
  }

  MenuButton {
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 30
    text: qsTr("Continue")
    onClicked: window.state = "main"
  }

  function enterScene() {

    if(lastScore > maximumHighscore) {
      maximumHighscore = lastScore;
      newMaximumHighscore.visible = true;
    } else
      newMaximumHighscore.visible = false;

    // Check achievements
    var grains = player.bonusScore;
    var deaths = player.deaths;

    console.log("Collected grains:", grains);
    if(gameCenter.authenticated) {
      if (grains >= 10)
        gameCenter.reportAchievement("grains10", 100, true);
      if (grains >= 25)
        gameCenter.reportAchievement("grains25", 100, true);
      if (grains >= 50)
        gameCenter.reportAchievement("grains50", 100, true);

      if (deaths >= 10)
        gameCenter.reportAchievement("chickendead1", 100, true);
    }

    console.log("Player's death count:", deaths);
  }

}
