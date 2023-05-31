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

Player.renderAsChildOf(PhysicsBody):
  this.sprite.render(ctx, this.x + offsetX, this.y + offsetY)

