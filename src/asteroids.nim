import shade

import std/[random, exitprocs]

import asteroidspkg/player as playerModule
import asteroidspkg/objects/asteroid as asteroidModule
import asteroidspkg/stars/star as starModule
import asteroidspkg/stars/starfield as starfieldModule
import asteroidspkg/ui/mainmenu as mainmenuModule
import asteroidspkg/ui/controlsmenu as controlsmenuModule
import asteroidspkg/controls as controlsModule

randomize()

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

# TODO: Fine-tune spatial grid once play area has been defined.
let layer = newPhysicsLayer(newSpatialGrid(100, 100, 600), gravity = VECTOR_ZERO)
Game.scene.addLayer layer

let camera = newCamera()
Game.scene.camera = camera

let player = newPlayer()
player.x = windowWidth / 2
player.y = windowHeight / 2

# Track the player with the camera.
camera.setLocation(player.x, player.y)

let starfield = newStarField(camera)
layer.addChild(starfield)

let root = newUIComponent()
Game.setUIRoot(root)

let mainMenu = newMainMenu()
root.addChild(mainMenu)

# TODO: Play around with this
const
  spawnRange = -5_000.0 .. 5_000.0
  velocityRange = -500 .. 500
for k in 0 .. 100:
  let asteroid = newAsteroid()
  asteroid.velocity = vector(rand(velocityRange), rand(velocityRange))
  asteroid.setLocation(player.x + rand(spawnRange), player.y + rand(spawnRange))
  layer.addChild(asteroid)

var gameIsPlaying = false

proc startGame() =
  starfield.stopMoving()
  layer.addChild(player)
  mainMenu.disableAndHide()
  gameIsPlaying = true

Input.onKeyEvent:
  if state.justPressed and key == K_ESCAPE and gameIsPlaying:
    starfield.startMoving()
    layer.removeChild(player)
    mainMenu.enableAndSetVisible()
    gameIsPlaying = false
    player.velocity = VECTOR_ZERO

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
let someSong = loadMusic("./assets/music/bipolarity.ogg")
if someSong != nil:
  fadeInMusic(someSong, 2.0)
else:
  echo "Error playing music"

Game.start()

# Save changes to any controls when the application exits.
addExitProc(saveControlsToFile)

