## Window Manager

import
  sdl2,

  exception

type
  WindowManager* = ref object of RootObj
    window: WindowPtr
    renderer: RendererPtr

proc newWindowManager*(window: WindowPtr, renderer: RendererPtr): WindowManager =
  ## Create new window manager.
  new result

  result.window = window
  result.renderer = renderer

proc getWindowSize*(self: WindowManager): tuple[width, height: int] =
  ## Get window size.
  var width, height: cint
  self.window.getSize(width, height)
  return (width: width.int, height: height.int)

proc setWindowSize*(self: WindowManager; width, height: int) =
  ## Set window size.
  self.window.setSize(width.cint, height.cint)

proc getResolution*(self: WindowManager): tuple[width, height: int] =
  ## Get window resolution.
  var width, height: cint
  self.renderer.getLogicalSize(width, height)
  return (width: width.int, height: height.int)

proc setResolution*(self: WindowManager; width, height: int) =
  ## Set window resolution.
  if self.renderer.setLogicalSize(width.cint, height.cint) < 0:
    raise newTinamouException(RENDERER_CONFIG_ERROR_CODE, "Could not set resolution (" & $width & ", " & $height & "). " & $sdl2.getError())

proc isFullScreen*(self: WindowManager): bool =
  ## Check if the window is fullscreen.
  return (self.window.getFlags() and SDL_WINDOW_FULLSCREEN) != 0

proc setFullScreen*(self: WindowManager, flag: bool) =
  ## Change fullscreen flag.
  if not self.window.setFullscreen(if flag: SDL_WINDOW_FULLSCREEN_DESKTOP else: 0):
    raise newTinamouException(FULLSCREEN_ERROR, "Could not set full screen. " & $sdl2.getError())

proc alert*(self: WindowManager, message: string, title: string = "") =
  ## Pop up alert window.
  discard showSimpleMessageBox(message = message, title = title, flags = SDL_MESSAGEBOX_WARNING, window = self.window)
