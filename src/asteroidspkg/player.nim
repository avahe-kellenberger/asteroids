import shade

const playerScale = 2.0

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

template rotateToCursor(this: Player) =
  let mouseLocInWorld = Game.scene.camera.screenToWorldCoord(Input.mouseLocation())
  let angleToMouse = this.getLocation().getAngleTo(mouseLocInWorld)
  this.rotation = angleToMouse
  this.sprite.rotation = angleToMouse

method update*(this: Player, deltaTime: float) =
  procCall Node(this).update(deltaTime)

  this.rotateToCursor()

Player.renderAsChildOf(PhysicsBody):
  this.sprite.render(ctx, this.x + offsetX, this.y + offsetY)

