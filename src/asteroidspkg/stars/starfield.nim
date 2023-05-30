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

type StarField = ref object
  camera: Camera
  starLayerPool: ObjectPool[Layer]
  starPool: ObjectPool[Star]

  layers: seq[Layer]
  nextLayerInterval: float

  starsToCreate: int
  starArea: AABB

proc calculateStarArea(): AABB
proc createStarLayer(): Layer

proc newStarField*(camera: Camera): StarField =
  result = StarField()
  result.camera = camera
  result.starLayerPool = newObjectPool[Layer](createStarLayer)
  result.starPool = newObjectPool[Star](newStar)
  result.starArea = calculateStarArea()

template calculateNextLayerInterval(): float =
  SPAWN_INTERVAL.random()

proc calculateStarArea(): AABB =
  let scaledResolution = gamestate.resolution * SPAWN_DISTANCE
  return aabb(0, 0, scaledResolution.x, scaledResolution.y)

template calculateStarsToCreate(starArea: AABB): int =
  int(starArea.getArea() * STAR_DENSITY)

proc createStarLayer(): Layer =
  # TODO
  discard

proc pruneLayers(this: StarField) =
  # TODO
  discard

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
    star.setLocation(this.starArea.getRandomPoint())
    result.addChild(star)

proc spawnLayers(this: StarField) =
  ## Spawns layers until the star field is populated at the required intervals.
  var spawnedLayer: Layer = this.spawnLayer()
  while spawnedLayer != nil:
    this.layers.add(spawnedLayer)
    this.nextLayerInterval = calculateNextLayerInterval()

proc translateZ(this: StarField, deltaZ: float) =
  ## Translates all layers by the delta Z order.
  for layer in this.layers:
    layer.z = (layer.z + deltaZ)

proc update*(this: StarField, deltaTime: float) =
  this.pruneLayers()
  this.spawnLayers()

  for layer in this.layers:
    layer.update(deltaTime)

StarField.render:
  # TODO: Set alpha of ctx (uint8) if fading in
  # ctx.color.a = 100
  for i in countdown(this.layers.len - 1, 0):
    this.layers[i].render(ctx, offsetX, offsetY)

