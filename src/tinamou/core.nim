## Tinamou Core Utilities

import
  # std
  math,
  times,

  # sdl2
  sdl2,
  sdl2.image,
  sdl2.ttf,
  sdl2.mixer,

  # tinamou
  exception,
  scene,
  painter

const
  errorLogFileName: string = "TinamouError.log"

proc calcFPSMaker(startTicks: uint32, interval: int = 30): (proc (ticks: uint32): float) =
  var
    prevTicks: uint32 = startTicks
    currentFPS: float = 0
    ticksHistory: seq[uint32] = @[]

  return proc (ticks: uint32): float =
    ticksHistory.add(ticks - prevTicks)
    prevTicks = ticks

    if ticksHistory.len >= interval:
      currentFPS = (ticksHistory.len * 1000).float / sum(ticksHistory).float
      ticksHistory = @[]

    return currentFPS

var
  quitDialogButtons: array[2, MessageBoxButtonData] = [
    MessageBoxButtonData(flags: SDL_MESSAGEBOX_BUTTON_ESCAPEKEY_DEFAULT, buttonid: 0, text: "cancel"),
    MessageBoxButtonData(flags: SDL_MESSAGEBOX_BUTTON_RETURNKEY_DEFAULT, buttonid: 1, text: "OK")]
  quitDialogData: MessageBoxData =
    MessageBoxData(flags: SDL_MESSAGEBOX_WARNING, window: nil, title: "Confirmation", message: "Are you sure you want to quit?", numbuttons: 2, buttons: cast[ptr MessageBoxButtonData](addr quitDialogButtons), colorScheme: nil)

proc startGame*(firstScene: TBaseScene; title: string; width, height: int = 600; showFPS: bool = false) =
  ## Start the game

  if not sdl2.init(INIT_VIDEO or INIT_AUDIO or INIT_TIMER or INIT_EVENTS):
    raise newTinamouException(INIT_ERROR_CODE, "SDL2 Initialization failed. " & $sdl2.getError())
  defer: sdl2.quit()

  if image.init(IMG_INIT_JPG or IMG_INIT_PNG) == 0:
    raise newTinamouException(INIT_ERROR_CODE, "SDL2_Image Initialization failed. " & $sdl2.getError())
  defer: image.quit()

  if not ttfInit():
    raise newTinamouException(INIT_ERROR_CODE, "SDL2_ttf Initialization failed. " & $sdl2.getError())
  defer: ttfQuit()

  if openAudio(mixer.MIX_DEFAULT_FREQUENCY, mixer.MIX_DEFAULT_FORMAT, 2, 1024) < 0:
    raise newTinamouException(INIT_ERROR_CODE, "SDL2_mixer Initialization failed. " & $sdl2.getError())
  defer:
    closeAudio()
    mixer.quit()

  if not sdl2.setHint("SDL_RENDER_SCALE_QUALITY", "best"):
    raise newTinamouException(INIT_TEXTURE_FILTERING_ERROR_CODE, "Linear texture filtering could not be enabled. " & $sdl2.getError())

  let window = createWindow(
    title = title,
    x = SDL_WINDOWPOS_CENTERED, y = SDL_WINDOWPOS_CENTERED,
    w = width.cint, h = height.cint,
    flags = SDL_WINDOW_SHOWN)
  if window.isNil:
    raise newTinamouException(WINDOW_CREATION_ERROR_CODE, "Window could not be created. " & $sdl2.getError())
  defer: destroy window

  let renderer = window.createRenderer(index = -1,
    flags = Renderer_Accelerated or Renderer_PresentVSync)
  if renderer.isNil:
    raise newTinamouException(RENDERER_CREATION_ERROR_CODE, "Renderer could not be created. " & $sdl2.getError())
  defer: destroy renderer

  # if renderer.setLogicalSize(width.cint, height.cint) != 0:
  #   raise newTinamouException(RENDERER_CONFIG_ERROR_CODE, "Renderer could not be configured resolution. " & $sdl2.getError())

  # Initialize tools.
  let
    painter: TPainter = newTPainter(renderer)
    tools: TTools = newTools(renderer)
    actions: TActions = newActions()
  defer: destroy tools

  let calcFPS = calcFPSMaker(getTicks())

  # Declare variables.
  var
    q: bool = false
    e: Event = sdl2.defaultEvent

    currentScene = firstScene

  try:
    currentScene.init(tools)

    # Start game-loop.
    while not q:

      # Event handling.
      while e.pollEvent():

        if e.kind == QuitEvent:
          ## TODO: quit handlinng
          var buttonId: cint
          if showMessageBox(messageboxdata = addr quitDialogData, buttonid = buttonId) < 0:
            raise newTinamouException(WINDOW_CREATION_ERROR_CODE, "Could not show quit dialog.")
          elif buttonId == 1:
            q = true

        actions.update(e)

      # Drawing.
      currentScene.draw(painter, tools, actions)
      painter.present()

      # Update states.
      let
        transition = currentScene.update(tools, actions)

      if transition.isStay():
        discard

      elif transition.isNext():
        # TODO: transition animation is not implemented yet
        currentScene = transition.getNextScene()
        currentScene.init(tools)

      elif transition.isFinal():
        q = true

      elif transition.isReset():
        currentScene = firstScene

      else:
        raise newTinamouException(UNKNOWN_TRANSITION_ERROR_CODE, "Unknown transition.")

      if showFPS:
        let fps = calcFPS(getTicks()).round(2)
        window.setTitle title & " (FPS = " & $fps & ")"

      frameEnd actions

  except TinamouException:

    # TODO: exception handling
    let currentException: ref TinamouException = cast[ref TinamouException](getCurrentException())

    try:
      let logFile: File = open(filename = errorLogFileName, mode = fmAppend)
      defer: close logFile

      logFile.write "Tinamou caught an exception!\nat: " & times.now().format("dd/MMM/yyyy HH:mm:ss ('GMT'z)") & "\n" & getCurrentExceptionMsg() & "\n"
      if stackTraceAvailable(): logFile.write getStackTrace(currentException)
      logFile.write "\n"

      stderr.write "Tinamou caught an exception!\nFor details, please see " & errorLogFileName & ".\n"

    except IOError:

      stderr.write "Tinamou caught an exception!\n" & getCurrentExceptionMsg() & "\n"
      if stackTraceAvailable(): stderr.write getStackTrace(currentException)
      stderr.write errorLogFileName & " file could not open."