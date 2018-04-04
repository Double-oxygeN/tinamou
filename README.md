# Tinamou

Game Library in Nim with SDL2

## How to Use

1. Prepare this library.
2. import `tinamou` module.
3. Create scenes. (See **How to Make Scenes**)
4. Do `startGame`.
5. That is all!

## Documentation

See http://double-oxygen.net/tinamou/tinamou.html

## How to Make Scenes

All you have to do first in order to make a scene is extend `TBaseScene`.

```nim
# Example
import tinamou
import colors

type
  ExScene = ref object of TBaseScene
    count: uint

  ExScene2 = ref object of TBaseScene

  ExScene3 = ref object of TBaseScene

```

Then override the methods.

```nim
proc newExScene(): ExScene =
  new result

method init(self: ExScene, tools: TTools) =
  # Scene initialization should be written in `init` method.
  self.count = 0

  tools.imageManager.setImage("imageName", "res/img/example.png")
  tools.imageManager.setSprite("spriteName", "res/img/sprite.png", spriteWidth = 32, spriteHeight = 32)

  tools.soundManager.setMusic("bgmName", "res/music/example.ogg")
  tools.soundManager.setEffect("seName", "res/se/example.wav")

  tools.soundManager.getMusic("bgmName").play()

method update(self: ExScene, tools: TTools, actions: TActions): TTransition =
  # What the scene do each frames should be written in `update` method.
  # This method returns scene transition.
  result = stay()

  self.count += 1

  if actions.keyboard.isPressed(SPACE):
    result = next(newExScene2())
  elif self.count >= 1200:
    result = next(newExScene3())
  elif actions.mouse.isPressed(RIGHT):
    tools.soundManager.getEffect("seName").play()

method draw(self: ExScene, painter: TPainter, tools: TTools, actions: TActions) =
  # Output to the screen should be written in `draw` method.
  painter.clear(colWhite)

  painter.drawImage(tools.imageManager.getImage("imageName"), 100, 50, 100, 80)
  painter.drawImage(tools.imageManager.getImage("spriteName"), 200, 10, spriteNum = 2)

  painter.text($actions.mouse.getPosition(), 150, 50).fill(colBlack)

```

When starting the game, give the first argument of `startGame` the initial scene.

```nim
when isMainModule:
  startGame(firstScene = newExScene(), title = "Tinamou Example", width = 1200, height = 800, showFPS = true)

```

## License

MIT  
See LICENSE.

Copyright (c) 2018 Double_oxygeN
