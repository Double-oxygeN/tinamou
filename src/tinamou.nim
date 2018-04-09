## Tinamou Game Library

import
  tinamou.core,
  tinamou.scene,
  tinamou.imagemanager,
  tinamou.soundmanager,
  tinamou.windowmanager,
  tinamou.painter,
  tinamou.keyboard,
  tinamou.mouse,
  tinamou.tween

export
  core,
  scene,
  imagemanager,
  soundmanager,
  windowmanager,
  painter,
  keyboard,
  mouse,
  tween

type
  TestScene = ref object of TBaseScene

proc newTestScene: TestScene =
  new result

when isMainModule:
  echo "This file was compiled on ", CompileDate, " at ", CompileTime

  startGame newTestScene(), "foobar", 600, 400
