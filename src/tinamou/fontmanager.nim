## Font Manager

import
  tables,

  sdl2,
  sdl2.ttf,

  exception

type
  Font* = ref object of RootObj
    font: ttf.FontPtr

  FontSrc = ref object of RootObj
    src: string
    savedFonts: TableRef[Positive, Font]

  FontManager* = ref object of RootObj
    table: TableRef[string, FontSrc]

proc newFont(path: string, fontSize: Positive): Font =
  ## Create new font.
  new result
  if ttfWasInit():
    result.font = openFont(path, fontSize.cint)
    if result.font.isNil:
      raise newTinamouException(FONT_LOAD_ERROR_CODE, "Failed to load font " & path & ".")

  else:
    raise newTinamouException(INIT_ERROR_CODE, "SDL2_TTF was not initialized.")

proc getFontPtr*(self: Font): ttf.FontPtr = self.font

proc newFontSrc(path: string): FontSrc =
  ## Create new font source.
  new result
  result.src = path
  result.savedFonts = newTable[Positive, Font]()

proc getFont(self: FontSrc, size: Positive): Font =
  ## Get font of given font size.
  if self.savedFonts.hasKey(size):
    result = self.savedFonts[size]
  else:
    result = newFont(self.src, size)
    self.savedFonts.add(size, result)

proc newFontManager*: FontManager =
  ## Create new font manager.
  new result
  result.table = newTable[string, FontSrc]()

proc setFont*(self: FontManager, name, path: string): FontManager {.discardable.} =
  ## Set a font.
  if not self.table.hasKey(name):
    self.table.add(name, newFontSrc(path))

proc getFont*(self: FontManager, name: string, size: Positive): Font =
  ## Get a font.
  ## This method requires font size.
  if self.table.hasKey(name):
    return self.table[name].getFont(size)
  else:
    raise newTinamouException(FONT_NOT_FOUND_ERROR_CODE, "Font '" & name & "' was not registered.")

proc destroy*(self: FontManager) =
  ## Free font manager resources.
  for src in self.table.values:
    for font in src.savedFonts.values:
      ttf.close font.font

    clear src.savedFonts
  clear self.table
