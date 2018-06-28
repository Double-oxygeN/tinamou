## Keyboard Input

import
  sdl2

type
  KeyName* {.pure.} = enum
    KEYA, KEYB, KEYC, KEYD, KEYE, KEYF, KEYG, KEYH, KEYI, KEYJ, KEYK, KEYL, KEYM,
    KEYN, KEYO, KEYP, KEYQ, KEYR, KEYS, KEYT, KEYU, KEYV, KEYW, KEYX, KEYY, KEYZ,
    DIGIT0, DIGIT1, DIGIT2, DIGIT3, DIGIT4, DIGIT5, DIGIT6, DIGIT7, DIGIT8, DIGIT9,
    COMMA, PERIOD, SLASH, SEMICOLON, COLON, MINUS, AT, LEFTBRACKET, RIGHTBRACKET, UNDERSCORE,
    LEFT, UP, RIGHT, DOWN,
    ENTER, SPACE, SHIFT, BACKSPACE, ESCAPE, CTRL, ALT, META,
    F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12,
    UNKNOWN

  DetailedKeyState = enum
    up = 0, down, pressed, released

  Keyboard* = ref object of RootObj
    keyStates: array[KeyName, DetailedKeyState]

proc toKeyName(keyCode: cint): KeyName =
  ## Convert key code to key name.
  result = case keyCode
    of K_a: KeyName.KEYA
    of K_b: KeyName.KEYB
    of K_c: KeyName.KEYC
    of K_d: KeyName.KEYD
    of K_e: KeyName.KEYE
    of K_f: KeyName.KEYF
    of K_g: KeyName.KEYG
    of K_h: KeyName.KEYH
    of K_i: KeyName.KEYI
    of K_j: KeyName.KEYJ
    of K_k: KeyName.KEYK
    of K_l: KeyName.KEYL
    of K_m: KeyName.KEYM
    of K_n: KeyName.KEYN
    of K_o: KeyName.KEYO
    of K_p: KeyName.KEYP
    of K_q: KeyName.KEYQ
    of K_r: KeyName.KEYR
    of K_s: KeyName.KEYS
    of K_t: KeyName.KEYT
    of K_u: KeyName.KEYU
    of K_v: KeyName.KEYV
    of K_w: KeyName.KEYW
    of K_x: KeyName.KEYX
    of K_y: KeyName.KEYY
    of K_z: KeyName.KEYZ
    of K_0, K_KP_0: KeyName.DIGIT0
    of K_1, K_KP_1: KeyName.DIGIT1
    of K_2, K_KP_2: KeyName.DIGIT2
    of K_3, K_KP_3: KeyName.DIGIT3
    of K_4, K_KP_4: KeyName.DIGIT4
    of K_5, K_KP_5: KeyName.DIGIT5
    of K_6, K_KP_6: KeyName.DIGIT6
    of K_7, K_KP_7: KeyName.DIGIT7
    of K_8, K_KP_8: KeyName.DIGIT8
    of K_9, K_KP_9: KeyName.DIGIT9
    of K_COMMA: KeyName.COMMA
    of K_PERIOD: KeyName.PERIOD
    of K_SLASH: KeyName.SLASH
    of K_SEMICOLON: KeyName.SEMICOLON
    of K_COLON: KeyName.COLON
    of K_MINUS: KeyName.MINUS
    of K_AT: KeyName.AT
    of K_LEFTBRACKET: KeyName.LEFTBRACKET
    of K_RIGHTBRACKET: KeyName.RIGHTBRACKET
    of K_UNDERSCORE: KeyName.UNDERSCORE
    of K_LEFT: KeyName.LEFT
    of K_UP: KeyName.UP
    of K_RIGHT: KeyName.RIGHT
    of K_DOWN: KeyName.DOWN
    of K_RETURN, K_RETURN2, K_KP_ENTER: KeyName.ENTER
    of K_SPACE: KeyName.SPACE
    of K_LSHIFT, K_RSHIFT: KeyName.SHIFT
    of K_BACKSPACE: KeyName.BACKSPACE
    of K_ESCAPE: KeyName.ESCAPE
    of K_LCTRL, K_RCTRL: KeyName.CTRL
    of K_LALT, K_RALT: KeyName.ALT
    of K_LGUI, K_RGUI: KeyName.META
    of K_F1: KeyName.F1
    of K_F2: KeyName.F2
    of K_F3: KeyName.F3
    of K_F4: KeyName.F4
    of K_F5: KeyName.F5
    of K_F6: KeyName.F6
    of K_F7: KeyName.F7
    of K_F8: KeyName.F8
    of K_F9: KeyName.F9
    of K_F10: KeyName.F10
    of K_F11: KeyName.F11
    of K_F12: KeyName.F12
    else: KeyName.UNKNOWN

proc newKeyboard*(): Keyboard =
  ## Create new keyboard.
  new result

proc isDown*(self: Keyboard, keyNames: varargs[KeyName]): bool =
  ## Check if any key of key names is down or pressed now.
  result = false
  for keyName in keyNames:
    if self.keyStates[keyName] == down or self.keyStates[keyName] == pressed: return true

proc isPressed*(self: Keyboard, keyNames: varargs[KeyName]): bool =
  ## Check if any key of key names is now pressed.
  result = false
  for keyname in keyNames:
    if self.keyStates[keyName] == pressed: return true

proc isReleased*(self: Keyboard, keyNames: varargs[KeyName]): bool =
  ## Check if any key of keynames is now released.
  result = false
  for keyName in keyNames:
    if self.keyStates[keyName] == released: return true

proc update*(self: Keyboard, event: Event) =
  ## Update keyboard state by event.
  case event.kind
  of KeyDown:
    if not self.isDown(event.key.keysym.sym.toKeyName):
      self.keyStates[event.key.keysym.sym.toKeyName] = pressed
  of KeyUp:
    self.keyStates[event.key.keysym.sym.toKeyName] = released
  else:
    discard

proc frameEnd*(self: Keyboard) =
  ## Tell keyboard the end of a frame.
  for keyName in KeyName:
    if self.keyStates[keyName] == pressed:
      self.keyStates[keyName] = down
    elif self.keyStates[keyName] == released:
      self.keyStates[keyName] = up

proc getPressingKeyNames*(self: Keyboard): seq[KeyName] =
  ## Get pressing key names.
  for keyName in KeyName:
    if self.isPressed keyName: result.safeAdd keyName
