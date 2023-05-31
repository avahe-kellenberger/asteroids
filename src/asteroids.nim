import shade
import asteroidspkg/player as playerModule
import asteroidspkg/stars/star as starModule
import asteroidspkg/stars/starfield as starfieldModule
import asteroidspkg/ui/mainmenu as mainmenuModule

initEngineSingleton(
  "Asteroids",
  1920,
  1080,
  fullscreen = true
)

let layer = newPhysicsLayer(gravity = VECTOR_ZERO)
Game.scene.addLayer layer

let player = newPlayer()
player.x = 1920 / 2
player.y = 640
# TODO: Add the player once the game has started.
# layer.addChild(player)

# Track the player with the camera.
let camera = newCamera(player, 0.25, easeInAndOutQuadratic)
Game.scene.camera = camera
camera.setLocation(player.x, player.y)

let starfield = newStarField(camera)
layer.addChild(starfield)

let root = newUIComponent()
Game.setUIRoot(root)

let mainMenu = newMainMenu()
root.addChild(mainMenu)

mainMenu.playText.onPressed:
  starfield.stopMoving()

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

player.onUpdate = proc(this: Node, deltaTime: float) =
  # Face player toward cursor
  let mouseLocInWorld = camera.screenToWorldCoord(Input.mouseLocation())
  let angleToMouse = player.getLocation().getAngleTo(mouseLocInWorld)
  player.rotation = angleToMouse
  player.sprite.rotation = angleToMouse

Input.onKeyEvent:
  case key:
    of K_ESCAPE:
      Game.stop()
    else:
      discard

# Play some music
let someSong = loadMusic("./assets/music/bipolarity.ogg")
if someSong != nil:
  fadeInMusic(someSong, 2.0)
else:
  echo "Error playing music"

Game.start()

