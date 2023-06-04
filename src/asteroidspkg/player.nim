import shade
import controls

const
  playerScale = 2.0
  acceleration = 10.0
  decceleration = 0.992
  maxSpeed = 500.0

type Player* = ref object of PhysicsBody
  sprite*: Sprite

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

method update*(this: Player, deltaTime: float) =
  procCall PhysicsBody(this).update(deltaTime)

  # Rotate player to cursor
  let thisLoc = this.getLocation()
  let mouseLocInWorld = Game.scene.camera.screenToWorldCoord(Input.mouseLocation())
  let angleRadiansToMouse = thisLoc.getAngleRadiansTo(mouseLocInWorld)
  let angleToMouse = angleRadiansToMouse.toAngle()
  this.rotation = angleToMouse
  this.sprite.rotation = angleToMouse

  if Input.isKeyPressed(slowDownControl.key):
    this.velocity *= decceleration
    if this.velocity.getMagnitude() <= (maxSpeed / 50):
      this.velocity = VECTOR_ZERO

  elif Input.isKeyPressed(thrustControl.key):
    this.velocity += fromRadians(angleRadiansToMouse) * acceleration
    this.velocity = this.velocity.maxMagnitude(maxSpeed)

  # Move the camera to track a position between the player and cursor.
  let cameraTrackedPosition = thisLoc + ((mouseLocInWorld - thisLoc) * 0.33)
  Game.scene.camera.move((cameraTrackedPosition - Game.scene.camera.getLocation()) * (5 * deltaTime))

Player.renderAsChildOf(PhysicsBody):
  this.sprite.render(ctx, this.x + offsetX, this.y + offsetY)
  this.collisionShape.stroke(ctx, this.x + offsetX, this.y + offsetY, RED)

