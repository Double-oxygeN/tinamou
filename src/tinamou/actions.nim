## User Input Managers

import
  sdl2,
  keyboard,
  mouse

type
  Actions* = ref object of RootObj
    mouse: Mouse
    keyboard: Keyboard

proc newActions*(): Actions =
  ## Create new actions.
  new result
  result.mouse = newMouse()
  result.keyboard = newKeyboard()

proc mouse*(self: Actions): Mouse = self.mouse
proc keyboard*(self: Actions): Keyboard = self.keyboard

proc update*(self: Actions, event: Event) =
  ## Update actions.
  self.keyboard.update(event)
  self.mouse.update(event)

proc frameEnd*(self: Actions) =
  ## Tell keyboard the end of a frame.
  frameEnd self.keyboard
  frameEnd self.mouse
