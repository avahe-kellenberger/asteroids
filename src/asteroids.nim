import shade
import asteroidspkg/player as playerModule
import asteroidspkg/stars/star as starModule

initEngineSingleton(
  "Asteroids",
  1200,
  900,
  fullscreen = false
)

Game.window.setWindowGrab(true)

let layer = newPhysicsLayer(gravity = VECTOR_ZERO)
Game.scene.addLayer layer

let player = newPlayer()
player.x = 1920 / 2
player.y = 640

# Track the player with the camera.
let camera = newCamera(player, 0.25, easeInAndOutQuadratic)
camera.z = 0.55
Game.scene.camera = camera
camera.setLocation(player.x, player.y)

layer.addChild(player)

let star = newStar()
star.setLocation(player.x + 20.0, player.y + 40.0)
layer.addChild(star)

# TODO:
# Player movement

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

Game.start()

