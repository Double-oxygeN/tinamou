## Scene and Transition

import
  # std
  colors,

  # sdl2
  sdl2,

  # painter
  painter,

  # tools
  imagemanager,
  soundmanager,
  windowmanager,
  fontmanager,

  # actions
  keyboard,
  mouse,

  # exception
  exception

type
  TransitionKind = enum
    ttstay, ttnext, ttfinal, ttreset

  SceneId* = string

  Transition* = object
    case kind: TransitionKind
    of ttnext:
      nextSceneId: SceneId
      sharedInfo: SharedInfo
    else:
      discard

  BaseScene* = ref object of RootObj

  SharedInfo* = ref object of RootObj

  Tools* = ref object of RootObj
    imageManager: ImageManager
    soundManager: SoundManager
    windowManager: WindowManager
    fontManager: FontManager

  Actions* = ref object of RootObj
    mouse: Mouse
    keyboard: Keyboard

let
  stayObj = Transition(kind: ttstay)
  finalObj = Transition(kind: ttfinal)
  resetObj = Transition(kind: ttreset)

  NOSHARE*: SharedInfo = new SharedInfo

proc stay*(): Transition =
  ## Stay current scene.
  stayObj

proc next*(sceneId: SceneId, sharedInfo: SharedInfo = NOSHARE): Transition =
  ## Transition to the next scene.
  Transition(kind: ttnext, nextSceneId: sceneId, sharedInfo: sharedInfo)

proc final*(): Transition =
  ## End the game.
  finalObj

proc reset*(): Transition =
  ## Reset the game.
  resetObj

proc isStay*(self: Transition): bool = self.kind == ttstay
proc isNext*(self: Transition): bool = self.kind == ttnext
proc isFinal*(self: Transition): bool = self.kind == ttfinal
proc isReset*(self: Transition): bool = self.kind == ttreset

proc getNextSceneId*(self: Transition): SceneId =
  if self.kind == ttnext:
    return self.nextSceneId
  else:
    raise newTinamouException(INVALID_TRANSITION_ERROR_CODE, "Only next transition has the next scene id.")

proc getSharedInfo*(self: Transition): SharedInfo =
  if self.kind == ttnext:
    return self.sharedInfo
  else:
    raise newTinamouException(INVALID_TRANSITION_ERROR_CODE, "Only next transition has the shared info.")

method init*(self: BaseScene, tools: Tools, info: SharedInfo) {.base.} =
  ## Scene initialization.
  discard

method update*(self: BaseScene, tools: Tools, actions: Actions): Transition {.base.} =
  ## Update the scene.
  ## Returns the transition.
  stay()

method draw*(self: BaseScene, painter: Painter, tools: Tools, actions: Actions) {.base.} =
  ## Output states to the window using painter.
  painter.clear(colBlack)

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

proc newActions*(): Actions =
  ## Create new actions.
  new result
  result.mouse = newMouse()
  result.keyboard = newKeyboard()

proc mouse*(self: Actions): Mouse = self.mouse
proc keyboard*(self: Actions): Keyboard = self.keyboard

proc update*(self: Actions, event: Event) =
  ## Update actions.
  self.keyboard.update(event)
  self.mouse.update(event)

proc frameEnd*(self: Actions) =
  ## Tell keyboard the end of a frame.
  frameEnd self.keyboard
  frameEnd self.mouse
