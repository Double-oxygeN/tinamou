## Mouse Input

import
  sdl2

type
  TDetailedKeyState = enum
    up = 0, down, pressed, released

  TMouseButton* {.pure.} = enum
    LEFT, RIGHT, MIDDLE, UNKNOWN

  TMouse* = ref object of RootObj
    buttonStates: array[TMouseButton, TDetailedKeyState]
    x, y: int # negative position means the pointer is out of window

proc toMouseButton(button: uint8): TMouseButton =
  ## Convert button code to button name.
  result = case button
    of BUTTON_LEFT: TMouseButton.LEFT
    of BUTTON_RIGHT: TMouseButton.RIGHT
    of BUTTON_MIDDLE: TMouseButton.MIDDLE
    else: TMouseButton.UNKNOWN

proc newMouse*(): TMouse =
  ## Create new mouse.
  new result
  result.x = -1
  result.y = -1

proc update*(self: TMouse, event: Event) =
  ## Update mouse state by event.
  case event.kind
  of MouseButtonDown:
    self.buttonStates[event.button.button.toMouseButton] = pressed
    self.x = event.button.x
    self.y = event.button.y
  of MouseButtonUp:
    self.buttonStates[event.button.button.toMouseButton] = released
    self.x = event.button.x
    self.y = event.button.y
  of MouseMotion:
    self.x = event.motion.x
    self.y = event.motion.y
  else:
    discard

proc frameEnd*(self: TMouse) =
  ## Tell keyboard the end of a frame.
  for button in TMouseButton:
    if self.buttonStates[button] == pressed:
      self.buttonStates[button] = down
    elif self.buttonStates[button] == released:
      self.buttonStates[button] = up

proc isDown*(self: TMouse, button: TMouseButton): bool =
  ## Check if the button is down or pressed now.
  return (self.buttonStates[button] == down) or (self.buttonStates[button] == pressed)

proc isPressed*(self: TMouse, button: TMouseButton): bool =
  ## Check if the button is now pressed.
  return self.buttonStates[button] == pressed

proc isReleased*(self: TMouse, button: TMouseButton): bool =
  ## Check if the button is now released.
  return self.buttonStates[button] == released

proc getPosition*(self: TMouse): tuple[x, y: int] =
  ## Get current mouse position.
  ## If mouse is out of window, then result is negative.
  return (x: self.x, y: self.y)
