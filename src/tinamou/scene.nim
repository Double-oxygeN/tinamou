## Scene

import
  colors,
  sdl2
import
  painter,
  tools,
  actions,
  exception,
  sharedinfo,
  transition

type
  BaseScene* = ref object of RootObj
    ## When you create scenes, extend it and implement methods.

method init*(self: BaseScene, tools: Tools, info: SharedInfo) {.base.} =
  ## Scene initialization.
  ## **Please implement it!**
  discard

method update*(self: BaseScene, tools: Tools, actions: Actions): Transition {.base.} =
  ## Update the scene.
  ## Returns the transition.
  ## **Please implement it!**
  stay()

method draw*(self: BaseScene, painter: Painter, tools: Tools, actions: Actions) {.base.} =
  ## Output states to the window using painter.
  ## **Please implement it!**
  painter.clear(colBlack)
