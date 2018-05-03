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
  scene.TBaseScene, scene.TTransition, scene.TTools, scene.TActions,
  scene.stay, scene.next, scene.final, scene.reset, scene.init, scene.update, scene.draw,
  scene.imageManager, scene.soundManager, scene.windowManager, scene.mouse, scene.keyboard,
  imagemanager,
  soundmanager,
  windowmanager,
  painter,
  keyboard.TKeyboard, keyboard.TKeyName, keyboard.isPressed, keyboard.isDown, keyboard.isReleased, keyboard.getPressingKeyNames,
  mouse.TMouse, mouse.TMouseButton, mouse.isPressed, mouse.isDown, mouse.isReleased, mouse.getPosition,
  tween

type
  TestScene = ref object of TBaseScene

proc newTestScene: TestScene =
  new result

when isMainModule:
  echo "This file was compiled on ", CompileDate, " at ", CompileTime

  startGame newTestScene(), "foobar", 600, 400
