import QtQuick 1.1
import Box2D 1.0
import VPlay 1.0
import "entities"
import "scripts/levelLogic.js" as LevelLogic

// the level gets moved in the negative y direction (so upwards)
Item {
  id: level
  // use the logical size as the level size
  width: scene.width

  // just as an abbreviation of typing, so instead of scene.gridSize just gridSize can be written in this file
  property real gridSize: scene.gridSize

  // available columns for creating roosts - the current logical scene width is 320, gridSize is 48, so 6 and a half roosts can be displayed horizontally
  property int roostColumns: width/gridSize

  // gets used to measure how much the level was moved downwards in the last frame - if this is bigger than gridSize, a new row will be created in onYChanged
  property real lastY: 0

  // how many new rows were created, it starts with 0 if the level has y position 0, and then gets increased with every gridSize
  // gets initialized in onCompleted
  property real currentRow: 0

  // this is needed so an alias can be created from the main window!
  property alias player: player

  // specifies the px/second how much the level moves
  property real levelMovementSpeedMinimum: 20
  property real levelMovementSpeedMaximum: 90
  // after 30seconds, the maximum speed will be reached - if you set this too high, also increase the gravity so the player falls faster than the level moves
  property int levelMovementDurationTillMaximum: 30

  // with 9% probability, a roost will get created in a row for any column
  // if it gets set too low, the game will be unplayable because too few roosts are created, so balance this with care!
  property real platformCreationProbability: 0.09
  // probability of 30% to create a corn on top of the roost, so in 3 of 10 roosts there will be a corn created
  property real coinCreationPropability: 0.3
  // windows get created randomly as well - they only have visual effect, but dont set too high because then it looks boring
  property real windowCreationProbability: 0.05
  // this avoids creating too many windows, so not possible to have more than 2 on a scene with this code!
  property real minimumWindowHeightDifference: 300

  // is needed internally to avoid creating too many windows close to each other
  property int lastWindowY: 0

  // the background images are moved up by this offset so on widescreen devices the full background is visible
  property real __yOffsetForWindow: scene.__yOffsetForAbsoluteWindowCoordinates

  // gets emitted when a BorderRegion.onPlayerCollision() is received
  signal gameLost

  Component.onCompleted: {

    // this creates some roosts, coins and windows beforehand, so they dont need to be created at runtime
    preCreateEntityPool();

    // startGame() is called in ChickenOutbreakScene.enterScene()
  }

  function preCreateEntityPool() {

    // dont pool entities on Sym & meego - creation takes very long on these platforms
    if(system.isPlatform(System.Meego) || system.isPlatform(System.Symbian))
      return;

    entityManager.createPooledEntitiesFromUrl(Qt.resolvedUrl("entities/Roost.qml"), 20);
    entityManager.createPooledEntitiesFromUrl(Qt.resolvedUrl("entities/HenhouseWindow.qml"), 5);
    entityManager.createPooledEntitiesFromUrl(Qt.resolvedUrl("entities/Coin.qml"), 10);
  }


  function stopGame() {
    levelMovementAnimation.stop();

    // this function automatically pools all entities which have poolingEnabled set to true
    // and it ignores the entities that have preventFromRemovalFromEntityManager set to true
    entityManager.removeAllEntities();
  }

  // initialize level data - this function can be called multiple times, so every time a new game gets started
  // it is called from ChickenOutbreakScene.enterScene()
  function startGame() {
    console.debug("Level: startGame()");

    // it is important that lastY is set first, so the dy in onYChanged will be 0 and no new row is created
    currentRow = 0;
    lastY = 0;

    level.y = 0;    

    player.x = scene.width/2;
    player.y = 2*gridSize;

    player.score = 0;
    player.bonusScore = 0;

    // this is required, otherwise after the game the player would still navigate left or right if no mouse release happened before, or when coming from the main scene it might still have the old direction
    player.controller.xAxis = 0;

    // this must be set BEFORE createRandomRowForRowNumber() is called!
    lastWindowY = 0;

    for(var i=5; i<15+10; i++) {
      LevelLogic.createRandomRowForRowNumber(i);
    }

    levelMovementAnimation.velocity = -levelMovementSpeedMinimum;
    levelMovementAnimation.start();
  }

  // this is the offset of the 2 backgrounds
  // make the offset a litte bit smaller, so no black background shines through when they are put below each other
  property real levelBackgroundHeight: levelBackground.height*levelBackground.scale-1

  // handles the repositioning of the background, if they are getting out of the scene
  // internally, 4 images are created below each other so it appears to the user as being one continuous background
  ParallaxScrollingBackground {
    id: levelBackground
    //x: gameWindowAnchorItem.x

    y: -level.y
    sourceImage: "img/background-wood2-sd.png"
    // do not mirror it vertically, because the image is prepared to match on the top and the bottom
    mirrorSecondImage: false
    movementVelocity: Qt.point(0, levelMovementAnimation.velocity)
    running: levelMovementAnimation.running // start non-running, gets set to true in startGame
  }

  // start in the center of the scene, and a little bit below the top
  // the player will fall to the playerInitialBlock below at start
  Player {
    id: player

    x: scene.width/2
    y: gridSize/2

    // this guarantees the player is in front of the henhouseWindows
    z: 1
  }

  // this guarantees the player doesnt fall through in the beginning
  Roost {
    id: lowerBlock
    // this id is used in BorderRegion to prevent this block from being removed!
    entityId: "playerInitialBlock"
    x: scene.width/2
    y: 3.5*gridSize // just a random position a little bit below the player

    // this keeps the entity from removeAllEntities()
    preventFromRemovalFromEntityManager: true
  }

  // the 2 BorderRegion entities (one on top and one on bottom of the screen) are not visible because they are offscreen
  // if the topRegion collides with a roost, a coin or a window, they get removed and used for pooling
  // if the topRegion collides with the player, that means the game is lost as the player got out of the scene on the top
  // the bottomRegion is only for detecting collision with the player, so if he falls through and cant stand on a roost, the game is lost
  BorderRegion {
    x: scene.gameWindowAnchorItem.x
    width: 2*scene.gameWindowAnchorItem.width // make bigger than the window, because the roost can stand out of the scene on the right side when the gridSize is not a multiple of the scene.width (which it currently is: 320/48=6.6) and thus if the player would stand on the right side no collision would be detected!
    variationType: "topRegion"

    // this height is not important, could also be set to 1 or anything else
    height: 20

    // this is important: the topRegion moves with the level, because the positions of the physics bodies do not move with the level position!
    // so the topRegion is always on the top of the scene + the height of the highest item (the window)
    // add 60 pixels (which is the height of the window), so it doesnt get removed while it is still visible!
    y: -level.y  -__yOffsetForWindow - height - 60

    onPlayerCollision: {
      console.debug("PLAYER COLLIDED WITH topRegion, level.y:", level.y, ", player.y:", player.y)
      // emit the gameLost signal, which is handled in ChickenOutbreakScene
      gameLost();
    }
  }
  BorderRegion {
    // make it so big that the player will still loose if he navigates to the right or left of the screen and then falls down
    width: scene.gameWindowAnchorItem.width*4
    anchors.horizontalCenter: parent.horizontalCenter

    height: 20
    // the BorderRegion is always out of the visual scene, so it is never visible
    // it moves with the level like the topRegion
    y: -level.y + scene.gameWindowAnchorItem.height

    variationType: "bottomRegion"

    onPlayerCollision: {
      console.debug("PLAYER COLLIDED WITH BorderRegion, level.y:", level.y, ", player.y:", player.y)
      // emit the gameLost signal, which is handled in ChickenOutbreakScene
      gameLost();
    }
  }

  MovementAnimation {
    id: levelMovementAnimation
    property: "y"
    // this is the movement in px per second, start with very slow movement, 10 px per second
    velocity: -levelMovementSpeedMinimum
    // running is set to false by default - start() is called in startGame()
    // increase the velocity by this amount of pixels per second, so it lasts minVelocity/acceleration seconds until the maximum is reached!
    // i.e. -90/-2 = 45 seconds
    acceleration: -(levelMovementSpeedMaximum-levelMovementSpeedMinimum) / levelMovementDurationTillMaximum
    target: level

    // limit the maximum v to 100 px per second - it must not be faster than the gravity! this is the absolute maximum, so the chicken falls almost as fast as the background moves by! so rather set it to -90, or increase the gravity
    minVelocity: -levelMovementSpeedMaximum
  }

  // when the level gets moved down, check if the difference between last level y position and the current one is greater than gridSize - if so, create a new row
  onYChanged: {
    // y gets more and more negative, so e.g. -40 - (-25) = -15
    var dy = y - lastY;
    if(-dy > gridSize) {

      var amountNewRows = (-dy/gridSize).toFixed();
      console.debug(amountNewRows, "new rows are getting created...")

      // if y changes a lot within the last frame, multiple rows might get created
      // this doesnt happen with fixed time delta, but it could happen with varying time delta where more than 1 row might need to be created because of such a big y delta
      for(var i=0; i<amountNewRows; i++) {
        currentRow++;
        // this guarantees it is created outside of the visual screen
        LevelLogic.createRandomRowForRowNumber(currentRow+25);
        // it's important to decrease lastY like that, not setting it to y!
        lastY -= gridSize
      }
    }

    // bitmap font for text updating is much faster -> this feature is not supported by V-Play yet, contact us if you would need it at support@v-play.net
      player.score = -(level.y/40).toFixed()
  }

  // ------------------- for debugging only ------------------- //
  function pauseGame() {
    console.debug("pauseGame()")
    levelMovementAnimation.stop();
  }
  function resumeGame() {
    console.debug("resumeGame()")
    levelMovementAnimation.start();
  }

  function restartGame() {
    console.debug("restartGame()")
    stopGame();
    startGame();
  }
}
