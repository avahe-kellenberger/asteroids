import shade
import asteroidspkg/player as playerModule

initEngineSingleton(
  "Asteroids",
  800,
  600,
  fullscreen = false,
  clearColor = newColor(91, 188, 228)
)

let layer = newPhysicsLayer(gravity = VECTOR_ZERO)
Game.scene.addLayer layer

let player = newPlayer()
player.x = 1920 / 2
player.y = 640

# Track the player with the camera.
let camera = newCamera(player, 0.25, easeInAndOutQuadratic)
camera.z = 0.55
Game.scene.camera = camera

layer.addChild(player)

# TODO:
# Movement
# Player facing cursor
# Hide cursor (replace with sprite)

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

