# Tinamou

Game Library in Nim with SDL2

## How to Use

1. Prepare this library.
    - Add `requires "tinamou"` in your `.nimble` file.
1. import `tinamou` module.
1. Create scenes. (See **How to Make Scenes**)
1. Do `startGame`.
1. That is all!

## Documentation

See http://double-oxygen.net/tinamou/tinamou.html

## How to Make Scenes

All you have to do first in order to make a scene is extend `BaseScene`.

```nim
# Example
import tinamou
import colors

type
  ExScene = ref object of BaseScene
    count: uint

  ExScene2 = ref object of BaseScene

  ExScene3 = ref object of BaseScene

```

Then override the methods.

```nim
proc newExScene(): ExScene =
  new result

method init(self: ExScene, tools: Tools, info: SharedInfo) =
  # Scene initialization should be written in `init` method.
  self.count = 0

  tools.imageManager.setImage("imageName", "res/img/example.png")
  tools.imageManager.setSprite("spriteName", "res/img/sprite.png", spriteWidth = 32, spriteHeight = 32)

  tools.soundManager.setMusic("bgmName", "res/music/example.ogg")
  tools.soundManager.setEffect("seName", "res/se/example.wav")

  tools.soundManager.getMusic("bgmName").play()

method update(self: ExScene, tools: Tools, actions: Actions): Transition =
  # What the scene do each frames should be written in `update` method.
  # This method returns scene transition.
  result = stay()

  self.count += 1

  if actions.keyboard.isPressed(SPACE):
    result = next("ex2")
  elif self.count >= 1200:
    result = next("ex3")
  elif actions.mouse.isPressed(RIGHT):
    tools.soundManager.getEffect("seName").play()

method draw(self: ExScene, painter: Painter, tools: Tools, actions: Actions) =
  # Output to the screen should be written in `draw` method.
  painter.clear(colWhite)

  painter.drawImage(tools.imageManager.getImage("imageName"), 100, 50, 100, 80)
  painter.drawImage(tools.imageManager.getImage("spriteName"), 200, 10, spriteNum = 2)

  painter.setFont("res/fonts/example.ttf", 48)
  painter.text($actions.mouse.getPosition(), 150, 50).fill(colBlack)

```

And then register all scenes into scene manager.
When starting the game, give the second argument of `startGame` the initial scene ID.

```nim
when isMainModule:
  let scenes = newSceneManager()
  scenes.setScene("ex1", newExScene())
  scenes.setScene("ex2", newExScene2())
  scenes.setScene("ex3", newExScene3())

  startGame(sceneManager = scenes, firstSceneId = "ex1", title = "Tinamou Example", width = 1200, height = 800, showFPS = true)

```

## License

MIT  
See LICENSE.

Copyright (c) 2018 Double_oxygeN
