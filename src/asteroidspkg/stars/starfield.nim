import shade
import star

const
  # The density of the stars to be displayed.
  STAR_DENSITY = 5.0e-10
  # Distance from the camera to spawn new star layers.
  SPAWN_DISTANCE = 250.0
  # The z distance interval between layers.
  SPAWN_INTERVAL = vector(10, 20)
  # The distance over which the star layers should fade in.
  FADE_DISTANCE = 50.0

template calculateStarsToCreate(starArea: AABB): int =
  int(starArea.getArea() * STAR_DENSITY)

type StarField = ref object of Node
  isAnimating*: bool
  camera: Camera
  layers: seq[Layer]
  starLayerPool: ObjectPool[Layer]
  starPool: ObjectPool[Star]

  nextLayerInterval: float

  starsToCreate: int
  starArea: AABB

proc calculateStarArea(camera: Camera): AABB
proc createStarLayer(): Layer

proc newStarField*(camera: Camera): StarField =
  result = StarField()
  initNode(Node result)
  result.isAnimating = true
  result.camera = camera
  result.starLayerPool = newObjectPool[Layer](createStarLayer)
  result.starPool = newObjectPool[Star](newStar)
  result.starArea = calculateStarArea(camera)

  result.starsToCreate = calculateStarsToCreate(result.starArea)

template calculateNextLayerInterval(): float =
  SPAWN_INTERVAL.random()

proc calculateStarArea(camera: Camera): AABB =
  let
    halfArea = camera.viewport.getSize() * SPAWN_DISTANCE * 0.5
    viewportCenter = camera.viewport.center()

  result = aabb(
    viewportCenter.x - halfArea.x,
    viewportCenter.y - halfArea.y,
    viewportCenter.x + halfArea.x,
    viewportCenter.y + halfArea.y
  )

proc createStarLayer(): Layer =
  return newLayer(0)

proc pruneLayers(this: StarField) =
  ## Prunes layers that are "behind" the camera from `this.layers`.
  if this.layers.len == 0:
    return

  var nextLayer = this.layers[0]
  while nextLayer != nil:
    if nextLayer.z > this.camera.z:
      break

    # Remove the first layer and preserve layer order.
    this.layers.delete(0)
    for child in nextLayer.childIterator:
      discard this.starPool.recycle(Star child)
      nextLayer.removeChild(child)

    discard this.starLayerPool.recycle(nextLayer)
    nextLayer = this.layers[0]

proc spawnLayer(this: StarField): Layer =
  ## Spawns a layer with stars.
  var zOrder: float = this.camera.z

  let lastlayerIndex = this.layers.len - 1
  if lastlayerIndex >= 0:
    let lastLayer = this.layers[lastlayerIndex]
    if (lastLayer.z - this.camera.z) >= (SPAWN_DISTANCE - this.nextLayerInterval):
      return nil
    zOrder = lastLayer.z

  zOrder += this.nextLayerInterval
  result = this.starLayerPool.get()
  result.z = zOrder

  # Populate layer with stars
  for i in countup(0, this.starsToCreate - 1):
    let star = this.starPool.get()
    star.sprite.scale = vector(100.0, 100.0)
    star.setLocation(this.starArea.getRandomPoint())
    result.addChild(star)

proc spawnLayers(this: StarField) =
  ## Spawns layers until the star field is populated at the required intervals.
  var spawnedLayer: Layer = this.spawnLayer()
  while spawnedLayer != nil:
    this.layers.add(spawnedLayer)
    this.nextLayerInterval = calculateNextLayerInterval()
    spawnedLayer = this.spawnLayer()

proc translateZ*(this: StarField, deltaZ: float) =
  ## Translates all layers by the delta Z order.
  for layer in this.layers:
    layer.z = (layer.z + deltaZ)

method update*(this: StarField, deltaTime: float) =
  procCall Node(this).update(deltaTime)

  if this.isAnimating:
    this.translateZ(-0.07)
    this.pruneLayers()
    this.spawnLayers()

  for layer in this.layers:
    layer.update(deltaTime)

StarField.renderAsNodeChild:
  for i in countdown(this.layers.len - 1, 0):
    let layer = this.layers[i]
    let dist = abs(SPAWN_DISTANCE - layer.z)
    let alpha = min(1.0, dist / FADE_DISTANCE)
    layer.forEachChild:
      Star(child).sprite.alpha = alpha
    ctx.renderLayer(this.camera, layer)

