import QtQuick 1.1
import VPlay 1.0
// Plugins
import VPlay.plugins.gamecenter 1.0
import VPlay.plugins.flurry 1.0

GameWindow {
  id: window
  // depending on which window size is defined as start resolution here, the corresponding image sizes get loaded here! so for testing hd2 images, at least use factor 3.5
  // the window size can be changed at runtime by pressing the keys 1-6 (see GameWindow.qml)
  width: 320*2//*1.5 // for testing on desktop with the highest res, use *1.5 so the -hd2 textures are used
  height: 480*2//*1.5

  // for better readability of the fps for QML renderer
  fpsTextItem.color: "white"

  // all properties assigned here are accessible from all entities!
  // the reason for that is, because entities get created through the EntityManager here in this GameWindow, and only the parent items of the item where it was created are known to the dynamically created entities
  property alias level: scene.level
  property alias player: scene.player // this works, when player is defined as alias in scene

  // for loading the stored highscore and displaying on GameOverScreen when a new highscore is reached
  // these get accessed from the MainScene and the ChickenOutbreakScene
  property int maximumHighscore: 0
  property int lastScore: 0
  Component.onCompleted: {
    var storedScore = settings.getValue("maximumHighscore");
    // if first-time use, nothing can be loaded and storedScore is undefined
    if(storedScore)
      maximumHighscore = storedScore;

    // Authenticate player to gamecenter
    gameCenter.authenticateLocalPlayer();    

    // this may be added to deactivate sounds in debug builds
//    if(system.debugBuild) {
//      settings.ignoredPropertiesForStoring = ["soundEnabled"]
//      settings.soundEnabled = false
//    }
    // enable System language for translations
    translation.useSystemLanguage = true
  }
  onMaximumHighscoreChanged: {
    var storedScore = settings.getValue("maximumHighscore");
    // if not stored anything yet, store the new value
    // or if a new highscore is reached, store that
    if(!storedScore || maximumHighscore > storedScore) {
      console.debug("stored improved highscore from", storedScore, "to", maximumHighscore);
      settings.setValue("maximumHighscore", maximumHighscore);
    }

    // Post highscore to gameCenter
    if (gameCenter.authenticated)
      gameCenter.reportScore(maximumHighscore);
  }

  // use BackgroundMusic for long-playing background sounds
  BackgroundMusic {
    id: backgroundMusic
    source: system.isPlatform(System.Meego) || system.isPlatform(System.Symbian) || system.isPlatform(System.BlackBerry) ? "snd/bg-slow-mono.ogg" : "snd/bg-slow.wav"

    // it is auto-played because autoplay is set to true by default!
  }

  // Custom font loading of ttf fonts
  FontLoader {
    id: fontHUD
    source: "fonts/munro.ttf"
  }

  // be sure to enable GameCenter for your application (developer.apple.com)
  GameCenter {
    id: gameCenter

    // Use highscore from GameCenter if it is higher than our local one
    onAuthenticatedChanged: {
      if (authenticated === true) {
        // For debugging only
        // resetAchievements();

        var gameCenterScore = getGameCenterScore();
        if (gameCenterScore > maximumHighscore)
          maximumHighscore = gameCenterScore;
      }
    }
  }

  // Flurry is only avaialable on iOS and Android
  Flurry {
    id: flurry
    // this is the app key for the ChickenOutbreak-SDK-Demo, be sure to get one for your own application if you want to use Flurry
    applicationKey: "9PH383W92BYDK6ZYVSDV"
  }


  // this scene is set to visible when loaded initially, so its opacity value gets set to 1 in a PropertyChange below
  MainScene {
    id: mainScene
    // when opacity is 0, visible gets set to false in SceneBase
    opacity: 0
  }

  ChickenOutbreakScene {
    id: scene
    // when opacity is 0, visible gets set to false in SceneBase
    opacity: 0
    onVisibleChanged: console.debug("GameScene changed visible to", visible)
  }

  GameOverScene {
    id: gameOverScene
    // when opacity is 0, visible gets set to false in SceneBase
    opacity: 0
  }

  CreditsScene {
    id: creditsScene
    // when opacity is 0, visible gets set to false in SceneBase
    opacity: 0
  }

  // for creating & removing entities
  EntityManager {
    id: entityManager
    entityContainer: scene.entityContainer    
    poolingEnabled: true // entity pooling works since version 0.9.4, so use it
  }

  // this gets used for analytics, to know which state was ended before
  property string lastActiveState: ""

  onStateChanged: {

    console.debug("ChickenBreakoutMain: changed state to", state)

    if(state === "main")
      activeScene = mainScene;
    else if(state === "game")
      activeScene = scene;
    else if(state === "gameOver")
      activeScene = gameOverScene;
    else if(state === "credits")
      activeScene = creditsScene;

    if(lastActiveState === "main") {
      flurry.endTimedEvent("Display.Main");
    } else if(lastActiveState === "game") {
      flurry.endTimedEvent("Display.Game");

      // NOTE: Android doesnt support endTimedEventWithParams yet!?! http://stackoverflow.com/questions/12205860/android-flurry-and-endtimedevent
      //flurry.endTimedEvent("Display.Game", { "score": lastScore, "collectedCorns" : player.bonusScore, "scoreForCorns": player.bonusScore*player.bonusScoreForCoin });
      // thus emit them with own events

      flurry.logEvent("Game.Finished", { "score": lastScore, "collectedCorns" : player.bonusScore, "scoreForCorns": player.bonusScore*player.bonusScoreForCoin })

    } else if(lastActiveState === "gameOver") {
      flurry.endTimedEvent("Display.GameOver");
    } else if(lastActiveState === "credits") {
      flurry.endTimedEvent("Display.Credits");
    }

    if(state === "main") {
      flurry.logTimedEvent("Display.Main");
    } else if(state === "game") {
      flurry.logTimedEvent("Display.Game");
    } else if(state === "gameOver") {
      flurry.logTimedEvent("Display.GameOver");
    } else if(state === "credits") {
      flurry.logTimedEvent("Display.Credits");
    }

    lastActiveState = state;
  }

  state: "main"
  // use one of the following states to start with another state when launching the game
  //    state: "game"
  //state: "gameOver"

  // these states are switched when the play button is pressed in MainScene, when the game is lost and when the Continue button is pressed in GameOverScene
  states: [
    State {
      name: "main"
      // by switching the propery to 1, which is by default set to 0 above, the Behavior defined in SceneBase takes care of animating the opacity of the new Scene from 0 to 1, and the one of the old scene from 1 to 0
      PropertyChanges { target: mainScene; opacity: 1}

    },
    State {
      name: "game"
      PropertyChanges { target: scene; opacity: 1}
      StateChangeScript {
        script: {
          console.debug("entered state 'game'")
          scene.enterScene();
        }
      }
    },
    State {
      name: "gameOver"
      PropertyChanges { target: gameOverScene; opacity: 1}
      StateChangeScript {
        script: {
          console.debug("entered state 'gameOver'")
          gameOverScene.enterScene();
        }
      }
    },
    State {
      name: "credits"
      PropertyChanges { target: creditsScene; opacity: 1}

    }
  ]
}
