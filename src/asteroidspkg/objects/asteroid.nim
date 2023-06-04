import shade

const
  brown = newColor(51, 26, 0)
  lightBrown = newColor(96, 64, 32)

type Asteroid* = ref object of PhysicsBody

proc createRandomCollisionShape(): CollisionShape =
  let poly = createRandomConvex(12, 300, 300)
  result = newCollisionShape(poly)

proc newAsteroid*(): Asteroid =
  result = Asteroid()
  var collisionShape = createRandomCollisionShape()
  initPhysicsBody(PhysicsBody result, collisionShape)

Asteroid.renderAsChildOf(PhysicsBody):
  this.collisionShape.fill(ctx, this.x + offsetX, this.y + offsetY, brown)
  let oldThickness = setLineThickness(4.0)
  this.collisionShape.stroke(ctx, this.x + offsetX, this.y + offsetY, lightBrown)
  discard setLineThickness(oldThickness)

