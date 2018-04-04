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

  # actions
  keyboard,
  mouse

type
  TTransitionKind = enum
    ttstay, ttnext, ttfinal, ttreset

  TTransition* = object
    case kind: TTransitionKind
    of ttnext:
      nextScene: TBaseScene
    else:
      discard

  TBaseScene* = ref object of RootObj

  TTools* = ref object of RootObj
    imageManager: TImageManager
    soundManager: TSoundManager

  TActions* = ref object of RootObj
    mouse: TMouse
    keyboard: TKeyboard

let
  stayObj = TTransition(kind: ttstay)
  finalObj = TTransition(kind: ttfinal)
  resetObj = TTransition(kind: ttreset)

proc stay*(): TTransition =
  ## Stay current scene.
  stayObj

proc next*(scene: TBaseScene): TTransition =
  ## Transition to the next scene.
  TTransition(kind: ttnext, nextScene: scene)

proc final*(): TTransition =
  ## End the game.
  finalObj

proc reset*(): TTransition =
  ## Reset the game.
  resetObj

proc isStay*(self: TTransition): bool = self.kind == ttstay
proc isNext*(self: TTransition): bool = self.kind == ttnext
proc isFinal*(self: TTransition): bool = self.kind == ttfinal
proc isReset*(self: TTransition): bool = self.kind == ttreset

proc getNextScene*(self: TTransition): TBaseScene =
  if self.kind == ttnext:
    return self.nextScene
  else:
    raise Exception.newException "Only next transition has the next scene."

method init*(self: TBaseScene, tools: TTools) {.base.} =
  ## Scene initialization.
  discard

method update*(self: TBaseScene, tools: TTools, actions: TActions): TTransition {.base.} =
  ## Update the scene.
  ## Returns the transition.
  stay()

method draw*(self: TBaseScene, painter: TPainter, tools: TTools, actions: TActions) {.base.} =
  ## Output states to the window using painter.
  painter.clear(colBlack)

proc newTools*(renderer: RendererPtr, numchans: int = 16): TTools =
  ## Create new tools.
  new result
  result.imageManager = newImageManager(renderer)
  result.soundManager = newSoundManager(numchans)

proc imageManager*(self: TTools): TImageManager = self.imageManager
proc soundManager*(self: TTools): TSoundManager = self.soundManager

proc destroy*(self: TTools) =
  ## Free resources.
  destroy self.imageManager
  destroy self.soundManager

proc newActions*(): TActions =
  ## Create new actions.
  new result
  result.mouse = newMouse()
  result.keyboard = newKeyboard()

proc mouse*(self: TActions): TMouse = self.mouse
proc keyboard*(self: TActions): TKeyboard = self.keyboard

proc update*(self: TActions, event: Event) =
  ## Update actions.
  self.keyboard.update(event)
  self.mouse.update(event)

proc frameEnd*(self: TActions) =
  ## Tell keyboard the end of a frame.
  frameEnd self.keyboard
  frameEnd self.mouse
