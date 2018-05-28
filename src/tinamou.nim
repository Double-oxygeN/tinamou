## Tinamou Game Library

import
  tinamou.core,
  tinamou.scene,
  tinamou.scenemanager,
  tinamou.imagemanager,
  tinamou.soundmanager,
  tinamou.windowmanager,
  tinamou.painter,
  tinamou.keyboard,
  tinamou.mouse,
  tinamou.tween,
  tinamou.exception

export
  core,
  scene.TBaseScene, scene.TTransition, scene.TTools, scene.TActions, scene.TSharedInfo,
  scene.stay, scene.next, scene.final, scene.reset, scene.init, scene.update, scene.draw,
  scene.imageManager, scene.soundManager, scene.windowManager, scene.mouse, scene.keyboard,
  scene.TNOSHARE,
  scenemanager.TSceneManager, scenemanager.newSceneManager, scenemanager.setScene,
  imagemanager,
  soundmanager,
  windowmanager,
  painter,
  keyboard.TKeyboard, keyboard.TKeyName, keyboard.isPressed, keyboard.isDown, keyboard.isReleased, keyboard.getPressingKeyNames,
  mouse.TMouse, mouse.TMouseButton, mouse.isPressed, mouse.isDown, mouse.isReleased, mouse.getPosition,
  tween,
  exception.TinamouException, exception.`$`, exception.getErrorCode


when isMainModule:
  type
    TestScene = ref object of TBaseScene

  proc newTestScene: TestScene =
    new result
  
  let scenes = newSceneManager()
  scenes.setScene("test", newTestScene())

  echo "This file was compiled on ", CompileDate, " at ", CompileTime

  startGame scenes, "test", "foobar", 600, 400
