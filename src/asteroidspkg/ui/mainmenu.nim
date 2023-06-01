import shade
import common
import controlsmenu as controlsmenuModule

type MainMenu* = ref object of UIComponent
  playText*: UITextComponent
  controlsText*: UITextComponent
  optionsText*: UITextComponent
  exitText*: UITextComponent

  mainOptionsContainer: UIComponent
  controlsMenu: ControlsMenu

proc createMainOptionsContainer(this: MainMenu)
proc goToMainMenu*(this: MainMenu)
proc goToControlsMenu*(this: MainMenu)

proc newMainMenu*(): MainMenu =
  result = MainMenu()
  initUIComponent(UIComponent result)
  result.stackDirection = StackDirection.Vertical
  result.alignHorizontal = Alignment.Center
  result.alignVertical = Alignment.Center

  result.createMainOptionsContainer()
  result.addChild(result.mainOptionsContainer)

  result.controlsMenu = newControlsMenu()
  result.controlsMenu.disableAndHide()
  result.addChild(result.controlsMenu)

  let self = result
  Input.onKeyEvent:
    if key == K_ESCAPE and state.justPressed:
      self.goToMainMenu()

proc createMainOptionsContainer(this: MainMenu) =
  this.mainOptionsContainer = newUIComponent()
  this.mainOptionsContainer.stackDirection = StackDirection.Vertical
  this.mainOptionsContainer.alignHorizontal = Alignment.Center
  this.mainOptionsContainer.alignVertical = Alignment.Center

  let optionFont = getMenuItemFont()
  let title = newText(getTitleFont(), "Asteroids", WHITE)
  title.margin = 12.0
  this.mainOptionsContainer.addChild(title)

  this.playText = newText(optionFont, "Play", WHITE)
  this.controlsText = newText(optionFont, "Controls", WHITE)
  this.optionsText = newText(optionFont, "Options", WHITE)
  this.exitText = newText(optionFont, "Exit", WHITE)

  this.mainOptionsContainer.addChild(this.playText)
  this.mainOptionsContainer.addChild(this.controlsText)
  this.mainOptionsContainer.addChild(this.optionsText)
  this.mainOptionsContainer.addChild(this.exitText)

  this.controlsText.onPressed:
    this.goToControlsMenu()

proc goToMainMenu*(this: MainMenu) =
  # TODO: Do this for each menu entry.
  this.mainOptionsContainer.enableAndSetVisible()
  this.controlsMenu.disableAndHide()

proc goToControlsMenu*(this: MainMenu) =
  this.mainOptionsContainer.disableAndHide()
  this.controlsMenu.enableAndSetVisible()

