import tinamou
import unittest

suite "Core Test":
  test "should start the game by calling `startGame`":
    type
      TestScene = ref object of BaseScene

    let scenes = newSceneManager()
    scenes.setScene "test", new TestScene

    startGame(scenes, "test", "test", 640, 480, off)

