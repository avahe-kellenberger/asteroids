import shade

const fontPath = "./assets/fonts/mozart.ttf"

type MainMenu* = ref object of UIComponent
  playText*: UITextComponent
  controlsText*: UITextComponent
  optionsText*: UITextComponent
  exitText*: UITextComponent

proc newMainMenu*(): MainMenu =
  result = MainMenu()
  initUIComponent(UIComponent result)
  result.stackDirection = StackDirection.Vertical
  result.alignHorizontal = Alignment.Center
  result.alignVertical = Alignment.Center

  let optionFont = Fonts.load(fontPath, 90).font
  let title = newText(Fonts.load(fontPath, 144).font, "Asteroids", WHITE)
  title.margin = 12.0
  result.addChild(title)

  result.playText = newText(optionFont, "Play", WHITE)
  result.controlsText = newText(optionFont, "Controls", WHITE)
  result.optionsText = newText(optionFont, "Options", WHITE)
  result.exitText = newText(optionFont, "Exit", WHITE)

  result.addChild(result.playText)
  result.addChild(result.controlsText)
  result.addChild(result.optionsText)
  result.addChild(result.exitText)

  title.determineWidthAndHeight()
  result.playText.determineWidthAndHeight()
  result.controlsText.determineWidthAndHeight()
  result.optionsText.determineWidthAndHeight()
  result.exitText.determineWidthAndHeight()
