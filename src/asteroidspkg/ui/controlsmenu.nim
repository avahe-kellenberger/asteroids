import shade
import common

const
  buttonColor = newColor(0, 60, 179)
  buttonBorderColor = newColor(51, 87, 255)
  buttonSelectedColor = newColor(179, 60, 0)
  buttonSelectedBorderColor = newColor(255, 87, 0)

proc `$`(key: Keycode): string =
  return $getScancodeName(getScancodeFromKey(key))

type
  Control = ref object
    name: string
    key: KeyCode
    button: UITextComponent

  ControlsMenu* = ref object of UIComponent
    thrustControl: Control
    slowDownControl: Control
    # "Selected" meaning we're waiting for a keypress to register for the control.
    selectedControl: Control
    allControls: seq[Control]

proc createControl(this: ControlsMenu, name: string, currentKey: Keycode): Control
proc configureControlInputListener(this: ControlsMenu)

proc newControlsMenu*(thrustKey: Keycode = K_W): ControlsMenu =
  result = ControlsMenu()
  initUIComponent(UIComponent result)
  result.stackDirection = StackDirection.Vertical
  result.alignHorizontal = Alignment.Center
  result.alignVertical = Alignment.Center

  let title = newText(getTitleFont(), "Controls", WHITE)
  title.margin = 12.0
  result.addChild(title)

  result.thrustControl = result.createControl("Thrust", thrustKey)
  result.slowDownControl = result.createControl("Slow Down", K_S)

  result.configureControlInputListener()

proc configureControlInputListener(this: ControlsMenu) =
  Input.addKeyboardEventListener(proc(key: Keycode, state: KeyState) =
    if this.selectedControl == nil:
      return

    if state.justPressed and key != K_ESCAPE:
      let button = this.selectedControl.button
      button.text = $key
      button.determineWidthAndHeight()
      let square = max(button.width.pixelValue, button.height.pixelValue)
      button.width = square
      button.height = square
      button.backgroundColor = buttonColor
      button.borderColor = buttonBorderColor
      # Deselect the control.
      this.selectedControl = nil
  )

proc createControl(this: ControlsMenu, name: string, currentKey: Keycode): Control =
  result = Control(name: name, key: currentKey)

  let container = newUIComponent()
  container.stackDirection = StackDirection.Horizontal
  container.alignHorizontal = Alignment.SpaceEvenly
  container.alignVertical = Alignment.Center
  container.margin = 12.0
  container.width = ratio(0.5)
  this.addChild(container)

  # TODO: Used for debugging, delete later
  container.borderWidth = 2.0
  container.borderColor = RED

  let keyText = newText(getMenuItemFont(), name & ":", WHITE)
  container.addChild(keyText)
  container.height = keyText.height

  let keyButton = newText(getMenuItemFont(), $currentKey, WHITE)
  keyButton.textAlignHorizontal = TextAlignment.Center
  keyButton.textAlignVertical = TextAlignment.Center
  result.button = keyButton

  let square = max(keyButton.width.pixelValue, keyButton.height.pixelValue)
  keyButton.width = square
  keyButton.height = square
  keyButton.backgroundColor = buttonColor
  keyButton.borderWidth = 2.0
  keyButton.borderColor = buttonBorderColor

  let self = result
  keyButton.onPressed:
    for control in this.allControls:
      control.button.backgroundColor = buttonColor
      control.button.borderColor = buttonBorderColor

    keyButton.backgroundColor = buttonSelectedColor
    keyButton.borderColor = buttonSelectedBorderColor
    this.selectedControl = self

  container.addChild(keyButton)

  this.allControls.add(result)

