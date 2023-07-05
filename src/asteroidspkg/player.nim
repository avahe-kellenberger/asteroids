import shade
import controls
import std/random

const
  playerScale = 2.0
  acceleration = 10.0
  decceleration = 0.992
  maxSpeed = 500.0

type Player* = ref object of PhysicsBody
  sprite*: Sprite
  particleEmitter*: ParticleEmitter

proc createCollisionShape(scale: float): CollisionShape =
  let poly = newPolygon([
    vector(-8, -8),
    vector(7, -1),
    vector(7, 0),
    vector(-8, 7),
  ])
  result = newCollisionShape(poly.getScaledInstance(scale))
  result.material = initMaterial(1, 0, 0.97)

proc createPlayerSprite(scale: float): Sprite =
  let (_, image) = Images.loadImage("./assets/sprites/ship.png", FILTER_NEAREST)
  result = newSprite(image, 4, 7)
  result.scale = vector(scale, scale)

proc newPlayer*(): Player =
  result = Player(sprite: createPlayerSprite(playerScale))
  var collisionShape = createCollisionShape(playerScale)
  initPhysicsBody(PhysicsBody(result), collisionShape)

  proc updateParticle(p: var Particle, deltaTime: float) =
    let
      t = max(0, p.ttl / p.lifetime)
      t1 = easeOutQuadratic(0, 1.0, 1.0 - t)
      t2 = easeInQuadratic(0, 1.0, easeOutQuadratic(0, 1.0, t))
    p.color.g = uint8 easeInQuadratic(0, 152, t1)
    p.color.b = uint8 easeInQuadratic(0, 58, t1)
    p.color.a = uint8(t2 * 255)

  let player = result
  proc createParticle(): Particle =
    result = newParticle(RED, 4.0, rand(0.6 .. 0.85))
    result.onUpdate = updateParticle

  result.particleEmitter = newParticleEmitter(150, createParticle, 150)
  # Don't emit particles by default.
  result.particleEmitter.enabled = false

  result.particleEmitter.onParticleEmission = proc(p: var Particle) =
    # Create a vector pointing away from player.rotation (with some randomness around 180)
    let
      randomness = 40.0
      backwardsVector = fromAngle(
        (player.rotation + rand((180.0 - randomness) .. (180.0 + randomness))) mod 360.0
      )

    p.velocity = backwardsVector * 80.0

method update*(this: Player, deltaTime: float) =
  procCall PhysicsBody(this).update(deltaTime)

  let backwardsVector = fromAngle((this.rotation + 180.0) mod 360)
  this.particleEmitter.setLocation(this.getLocation() + backwardsVector * 4.0)
  this.particleEmitter.update(deltaTime)

  # Rotate player to cursor
  let thisLoc = this.getLocation()
  let mouseLocInWorld = Game.scene.camera.screenToWorldCoord(Input.mouseLocation())
  let angleRadiansToMouse = thisLoc.getAngleRadiansTo(mouseLocInWorld)
  let angleToMouse = angleRadiansToMouse.toAngle()
  this.rotation = angleToMouse
  this.sprite.rotation = angleToMouse

  let thrustKeyState = Input.getKeyState(thrustControl.key)
  if thrustKeyState.justPressed:
    this.particleEmitter.enabled = true
  elif thrustKeyState.justReleased:
    this.particleEmitter.enabled = false

  if thrustKeyState.pressed:
    this.velocity += fromRadians(angleRadiansToMouse) * acceleration
    this.velocity = this.velocity.maxMagnitude(maxSpeed)
  elif Input.isKeyPressed(slowDownControl.key):
    this.velocity *= decceleration
    if this.velocity.getMagnitude() <= (maxSpeed / 50):
      this.velocity = VECTOR_ZERO

  # Move the camera to track a position between the player and cursor.
  let cameraTrackedPosition = thisLoc + ((mouseLocInWorld - thisLoc) * 0.33)
  Game.scene.camera.move((cameraTrackedPosition - Game.scene.camera.getLocation()) * (5 * deltaTime))

Player.renderAsChildOf(PhysicsBody):
  this.particleEmitter.render(ctx, offsetX, offsetY)
  this.sprite.render(ctx, this.x + offsetX, this.y + offsetY)

