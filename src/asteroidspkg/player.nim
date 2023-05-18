import shade

type Player* = ref object of PhysicsBody
  sprite: Sprite

proc createCollisionShape(): CollisionShape =
  result = newCollisionShape(aabb(-8, -13, 8, 13))
  result.material = initMaterial(1, 0, 0.97)

proc createPlayerSprite(): Sprite =
  let (_, image) = Images.loadImage("./assets/sprites/ship.png", FILTER_NEAREST)
  result = newSprite(image, 4, 7)

proc newPlayer*(): Player =
  result = Player(sprite: createPlayerSprite())
  var collisionShape = createCollisionShape()
  initPhysicsBody(PhysicsBody(result), collisionShape)

  let sprite = createPlayerSprite()
  result.sprite = sprite

Player.renderAsChildOf(PhysicsBody):
  this.sprite.render(ctx, this.x + offsetX, this.y + offsetY)

