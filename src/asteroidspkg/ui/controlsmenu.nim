import shade
import common

const
  buttonColor = newColor(0, 60, 179)
  buttonBorderColor = newColor(51, 87, 255)

type ControlsMenu* = ref object of UIComponent
  thrustKey: Keycode

proc addControl(this: ControlsMenu, name: string, currentKey: Keycode, onKeycodeSet: proc(key: Keycode))

proc newControlsMenu*(thrustKey: Keycode = K_W): ControlsMenu =
  result = ControlsMenu(thrustKey: thrustKey)
  initUIComponent(UIComponent result)
  result.stackDirection = StackDirection.Vertical
  result.alignHorizontal = Alignment.Center
  result.alignVertical = Alignment.Center

  let title = newText(getTitleFont(), "Controls", WHITE)
  title.margin = 12.0
  result.addChild(title)

  let self = result
  result.addControl("Thrust", thrustKey, proc(key: Keycode) = self.thrustKey = key)

proc `$`(key: Keycode): string =
  return $getScancodeName(getScancodeFromKey(key))

proc addControl(this: ControlsMenu, name: string, currentKey: Keycode, onKeycodeSet: proc(key: Keycode)) =
  let container = newUIComponent()
  container.stackDirection = StackDirection.Horizontal
  container.alignHorizontal = Alignment.SpaceEvenly
  container.alignVertical = Alignment.Center
  container.margin = 12.0
  container.width = ratio(0.5)
  this.addChild(container)

  let keyText = newText(getMenuItemFont(), name & ":", WHITE)
  container.addChild(keyText)

  let keyButton = newText(getMenuItemFont(), $currentKey, WHITE)
  keyButton.textAlignHorizontal = TextAlignment.Center
  keyButton.textAlignVertical = TextAlignment.Center

  let square = max(keyButton.width.pixelValue, keyButton.height.pixelValue)
  keyButton.width = square
  keyButton.height = square
  keyButton.backgroundColor = buttonColor
  keyButton.borderWidth = 2.0
  keyButton.borderColor = buttonBorderColor

  container.addChild(keyButton)

