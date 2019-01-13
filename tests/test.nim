import tinamou
import unittest, macros

suite "core":
  test "should start the game by calling `startGame`":
    type
      TestScene = ref object of BaseScene

    let scenes = newSceneManager()
    scenes.setScene "test", new TestScene

    startGame(scenes, "test", "test", 640, 480, off)

type
  ShareBaz = ref object of SharedInfo
    baz*: tuple[a: bool, b: string]

proc newShareBaz(a: bool, b: string): ShareBaz =
  new result

  result.baz = (a, b)

createScene(Test1Scene):
  var foo: int
  var
    bar: float
    baz: tuple[a: bool, b: string]

  init:
    self.foo = 42
    self.bar = 2.8
    self.baz.a = true
    self.baz.b = "hello"

    tools.fontManager.setFont "test-font", "./tests/source-serif-pro/TTF/SourceSerifPro-Black.ttf"
    
  init[ShareBaz]:
    self.foo = 42
    self.bar = 2.8
    self.baz = info.baz
    tools.fontManager.setFont "test-font", "./tests/source-serif-pro/TTF/SourceSerifPro-Black.ttf"

  update:
    result = stay()

    if actions.keyboard.isPressed(KeyName.UP):
      inc self.foo

    if actions.keyboard.isPressed(KeyName.DOWN):
      dec self.foo

    if actions.keyboard.isPressed(KeyName.SPACE):
      result = next("test2")

  draw:
    painter.clear 0xff, 0xff, 0xff

    painter.setFont tools.fontManager.getFont("test-font", 64)
    painter.text($self.foo & ": " & self.baz.b, 320, 240, origin = OriginKind.C).fill(0, 0, 0x33)

createScene(Test2Scene):
  update:
    result = stay()

    if actions.keyboard.isPressed(KeyName.SPACE):
      result = next("test1", newShareBaz(false, "hi"))

  draw:
    painter.clear 0, 0, 0

suite "syntax":
  test "should create scene by using `createScene` macro":

    let scenes = newSceneManager()
    scenes.setScene "test1", new Test1Scene
    scenes.setScene "test2", new Test2Scene

    startGame(scenes, "test1", "syntax test", 640, 480, off)
