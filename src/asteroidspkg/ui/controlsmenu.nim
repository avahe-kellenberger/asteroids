import shade
import common
import ../controls

const
  buttonColor = newColor(0, 60, 179)
  buttonBorderColor = newColor(51, 87, 255)
  buttonSelectedColor = newColor(179, 60, 0)
  buttonSelectedBorderColor = newColor(255, 87, 0)

proc `$`(key: Keycode): string =
  return $getScancodeName(getScancodeFromKey(key))

type
  ControlComponent = ref object
    control: Control
    button: UITextComponent

  ControlsMenu* = ref object of UIComponent
    thrustControl: ControlComponent
    slowDownControl: ControlComponent
    # "Selected" meaning we're waiting for a keypress to register for the control.
    selectedControl: ControlComponent
    allControls: seq[ControlComponent]

proc createControlComponent(this: ControlsMenu, control: Control): ControlComponent
proc configureControlInputListener(this: ControlsMenu, returnToMainMenu: proc)

proc newControlsMenu*(returnToMainMenu: proc): ControlsMenu =
  result = ControlsMenu()
  initUIComponent(UIComponent result)
  result.stackDirection = StackDirection.Vertical
  result.alignHorizontal = Alignment.Center
  result.alignVertical = Alignment.Start
  result.margin = 48.0

  let title = newText(getTitleFont(), "Controls", WHITE)
  title.margin = margin(12, 12, 12, 72)
  result.addChild(title)

  result.thrustControl = result.createControlComponent(thrustControl)
  result.slowDownControl = result.createControlComponent(slowDownControl)

  result.configureControlInputListener(returnToMainMenu)

proc configureControlInputListener(this: ControlsMenu, returnToMainMenu: proc) =
  Input.addKeyboardEventListener(proc(key: Keycode, state: KeyState) =
    if not state.justPressed:
      return

    if this.selectedControl == nil:
      if key == K_ESCAPE:
        returnToMainMenu()
      return

    if state.justPressed:
      let button = this.selectedControl.button
      if key == K_ESCAPE:
        # Deselect key
        button.backgroundColor = buttonColor
        button.borderColor = buttonBorderColor
        this.selectedControl = nil
      else:
        this.selectedControl.control.key = key
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

proc createControlComponent(this: ControlsMenu, control: Control): ControlComponent =
  result = ControlComponent(control: control)

  let container = newUIComponent()
  container.stackDirection = StackDirection.Horizontal
  container.alignHorizontal = Alignment.SpaceEvenly
  container.alignVertical = Alignment.Center
  container.margin = 12.0
  container.width = ratio(0.3)
  this.addChild(container)

  let keyText = newText(getMenuItemFont(), control.name & ":", WHITE)
  container.addChild(keyText)
  container.height = keyText.height

  # Spacer to nicely align buttons
  container.addChild(newUIComponent())

  let keyButton = newText(getMenuItemFont(), $control.key, WHITE)
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

