import shade
import controls

const
  playerScale = 2.0
  acceleration = 100.0
  decceleration = 20.0
  maxSpeed = 10_000.0

type Player* = ref object of PhysicsBody
  sprite*: Sprite

proc createCollisionShape(scale: float): CollisionShape =
  result = newCollisionShape(aabb(-8, -13, 8, 13).getScaledInstance(scale))
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
  let mouseLocInWorld = Game.scene.camera.screenToWorldCoord(Input.mouseLocation())
  let angleRadiansToMouse = this.getLocation().getAngleRadiansTo(mouseLocInWorld)
  let angleToMouse = angleRadiansToMouse.toAngle()
  this.rotation = angleToMouse
  this.sprite.rotation = angleToMouse

  if Input.isKeyPressed(slowDownControl.key):
    this.velocity *= 0.992
    if this.velocity.getMagnitude() <= (maxSpeed / 50):
      this.velocity = VECTOR_ZERO

  elif Input.isKeyPressed(thrustControl.key):
    this.velocity += fromRadians(angleRadiansToMouse) * acceleration
    this.velocity = this.velocity.maxMagnitude(maxSpeed)


Player.renderAsChildOf(PhysicsBody):
  this.sprite.render(ctx, this.x + offsetX, this.y + offsetY)

