import shade
import std/[random, sequtils]

randomize()

const
  brown = newColor(51, 26, 0)
  lightBrown = newColor(96, 64, 32)

type Asteroid* = ref object of PhysicsBody
  subasteroids: seq[Asteroid]

proc createSquare(sideLength: Positive): Polygon =
  ## Creates a square of the given size.
  return newPolygon([
    vector(0, 0),
    vector(sideLength, 0),
    vector(sideLength, sideLength),
    vector(0, sideLength)
  ])

proc createSquareCollisionShape(sideLength: Positive): CollisionShape =
  return newCollisionShape(createSquare(sideLength))

proc newAsteroid*(): Asteroid =
  result = Asteroid()
  let sideLength = rand(100..400)
  var collisionShape = createSquareCollisionShape(sideLength)
  initPhysicsBody(PhysicsBody result, collisionShape)
  result.angularVelocity = rand(50.0) * sample([1.0, -1.0])

  # Create subasteroids that make up the parent
  let halfSideLength = sideLength / 2
  for i in 0..4:
    var subasteroid = Asteroid()
    var collisionShape = createSquareCollisionShape(sideLength)
    initPhysicsBody(PhysicsBody subasteroid, collisionShape)
    result.subasteroids.add(subasteroid)

    if i == 1:
      subasteroid.x = halfSideLength
    elif i == 2:
      subasteroid.setLocation(halfSideLength, halfSideLength)
    elif i == 3:
      subasteroid.y = halfSideLength

Asteroid.renderAsChildOf(PhysicsBody):
  this.collisionShape.fill(ctx, this.x + offsetX, this.y + offsetY, brown)
  let oldThickness = setLineThickness(4.0)
  this.collisionShape.stroke(ctx, this.x + offsetX, this.y + offsetY, lightBrown)
  discard setLineThickness(oldThickness)

