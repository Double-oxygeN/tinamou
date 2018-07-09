## Tools

import
  sdl2,
  imagemanager,
  soundmanager,
  windowmanager,
  fontmanager

type
  Tools* = ref object of RootObj
    imageManager: ImageManager
    soundManager: SoundManager
    windowManager: WindowManager
    fontManager: FontManager

proc newTools*(window: WindowPtr, renderer: RendererPtr, numchans: int = 16): Tools =
  ## Create new tools.
  new result
  result.imageManager = newImageManager(renderer)
  result.soundManager = newSoundManager(numchans)
  result.windowManager = newWindowManager(window, renderer)
  result.fontManager = newFontManager()

proc imageManager*(self: Tools): ImageManager = self.imageManager
proc soundManager*(self: Tools): SoundManager = self.soundManager
proc windowManager*(self: Tools): WindowManager = self.windowManager
proc fontManager*(self: Tools): FontManager = self.fontManager

proc destroy*(self: Tools) =
  ## Free resources.
  destroy self.imageManager
  destroy self.soundManager
  destroy self.fontManager
