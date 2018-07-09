## Transition for one scene.

import
  sharedinfo,
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

let
  stayObj = Transition(kind: ttstay)
  finalObj = Transition(kind: ttfinal)
  resetObj = Transition(kind: ttreset)

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
