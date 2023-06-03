import shade

import std/exitprocs

import asteroidspkg/player as playerModule
import asteroidspkg/stars/star as starModule
import asteroidspkg/stars/starfield as starfieldModule
import asteroidspkg/ui/mainmenu as mainmenuModule
import asteroidspkg/ui/controlsmenu as controlsmenuModule
import asteroidspkg/controls as controlsModule

loadControlsFromFile()

const
  windowWidth = 1920
  windowHeight = 1080

initEngineSingleton(
  "Asteroids",
  windowWidth,
  windowHeight,
  fullscreen = true
)

let layer = newPhysicsLayer(gravity = VECTOR_ZERO)
Game.scene.addLayer layer

let camera = newCamera(nil, 0.5, easeInAndOutQuadratic)
Game.scene.camera = camera

let player = newPlayer()
player.x = windowWidth / 2
player.y = windowHeight / 2

# Track the player with the camera.
camera.trackedNode = player
camera.setLocation(player.x, player.y)

let starfield = newStarField(camera)
layer.addChild(starfield)

let root = newUIComponent()
Game.setUIRoot(root)

let mainMenu = newMainMenu()
root.addChild(mainMenu)

proc startGame() =
  starfield.stopMoving()
  layer.addChild(player)
  mainMenu.disableAndHide()

mainMenu.playText.onPressed:
  startGame()

mainMenu.exitText.onPressed:
  Game.stop()

# Load custom cursor
block:
  let cursorSurface = loadSurface("assets/sprites/cursor.png")
  if cursorSurface == nil:
    raise newException(Exception, "Failed to load cursor image!")

  let cursor = createColorCursor(cursorSurface, cursorSurface.w div 2, cursorSurface.h div 2)
  setCursor(cursor)
  freeSurface(cursorSurface)

# Play some music
# let someSong = loadMusic("./assets/music/bipolarity.ogg")
# if someSong != nil:
#   fadeInMusic(someSong, 2.0)
# else:
#   echo "Error playing music"

Game.start()

# Save changes to any controls when the application exits.
addExitProc(saveControlsToFile)

