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

const
  maxSpeed = 400.0
  acceleration = 100.0
  jumpForce = -350.0

# TODO:
# Movement
# Player facing cursor
# Hide cursor (replace with sprite)

Input.onKeyEvent:
  if key == K_ESCAPE:
    Game.stop()

Game.start()

