## Tinamou Game Library

import
  tinamou.core,
  tinamou.scene,
  tinamou.scenemanager,
  tinamou.imagemanager,
  tinamou.soundmanager,
  tinamou.windowmanager,
  tinamou.fontmanager,
  tinamou.painter,
  tinamou.keyboard,
  tinamou.mouse,
  tinamou.tween,
  tinamou.exception

export
  core,
  scene.BaseScene, scene.Transition, scene.Tools, scene.Actions, scene.SharedInfo,
  scene.stay, scene.next, scene.final, scene.reset, scene.init, scene.update, scene.draw,
  scene.imageManager, scene.soundManager, scene.windowManager, scene.fontManager,
  scene.mouse, scene.keyboard, scene.NOSHARE,
  scenemanager.SceneManager, scenemanager.newSceneManager, scenemanager.setScene,
  imagemanager,
  soundmanager,
  windowmanager,
  fontmanager.Font, fontmanager.FontManager, fontmanager.setFont, fontmanager.getFont,
  painter,
  keyboard.Keyboard, keyboard.KeyName, keyboard.isPressed, keyboard.isDown, keyboard.isReleased, keyboard.getPressingKeyNames,
  mouse.Mouse, mouse.MouseButton, mouse.isPressed, mouse.isDown, mouse.isReleased, mouse.getPosition,
  tween,
  exception.TinamouException, exception.`$`, exception.getErrorCode


when isMainModule:
  type
    TestScene = ref object of BaseScene

  proc newTestScene: TestScene =
    new result

  let scenes = newSceneManager()
  scenes.setScene("test", newTestScene())

  echo "This file was compiled on ", CompileDate, " at ", CompileTime

  startGame scenes, "test", "foobar", 600, 400
