import shade

const
  fontPath* = "./assets/fonts/mozart.ttf"

var
  titleFont: Font = nil
  menuItemFont: Font = nil

proc getTitleFont*(): Font =
  if titleFont == nil:
    titleFont = Fonts.load(fontPath, 144).font
  return titleFont

proc getMenuItemFont*(): Font =
  if menuItemFont == nil:
    menuItemFont = Fonts.load(fontPath, 90).font
  return menuItemFont

