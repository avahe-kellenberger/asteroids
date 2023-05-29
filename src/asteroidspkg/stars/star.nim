import shade

const frameDuration = 0.07

var starImageId = -1

type Star* = ref object of Node
  sprite*: Sprite
  animPlayer: AnimationPlayer

proc createShineAnimation(this: Star): Animation =
  # Create each frame of the animation.
  var frames: seq[Keyframe[IVector]]

  # TODO: Animation is fucked up
  # frame indicies are correct,
  # hopefully not a bug in the engine's animation code.

  # Each frame from start to end.
  for y in countup(0, this.sprite.spritesheet.rows - 1):
    for x in countup(0, this.sprite.spritesheet.cols - 1):
      let frameIndex = x + (y * this.sprite.spritesheet.cols)
      let frame = (ivector(x, y), float(frameIndex) * frameDuration)
      frames.add(frame)

  # Loop back from the end to the start (not including first and last frames).
  for y in countdown(this.sprite.spritesheet.rows - 1, 0):
    for x in countdown(this.sprite.spritesheet.cols - 1, 0):
      let frameIndex = x + (y * this.sprite.spritesheet.cols)
      # Avoid duplication first and last frames of the animation.
      if frameIndex == 0 or frameIndex == this.sprite.numFrames - 1:
        continue

      let frame = (ivector(x, y), float(frameIndex) * frameDuration)
      frames.add(frame)

  let animDuration = float(frames.len) * frameDuration
  result = newAnimation(animDuration, true)

  let self = result
  self.addNewAnimationTrack(this.sprite.frameCoords, frames)

proc newStar*(): Star =
  result = Star()
  initNode(result)

  # Lazy load sprite image
  if starImageId == -1:
    starImageId = Images.loadImage("assets/sprites/star.png", FILTER_NEAREST).id
  result.sprite = newSprite(Images[starImageId], 4, 3)

  const animName = "shine"
  result.animPlayer = newAnimationPlayer()
  result.animPlayer.addAnimation(animName, result.createShineAnimation())
  result.animPlayer.play(animName)

method update*(this: Star, deltaTime: float) =
  procCall Node(this).update(deltaTime)
  this.animPlayer.update(deltaTime)

Star.renderAsNodeChild:
  this.sprite.render(ctx, this.x + offsetX, this.y + offsetY)

