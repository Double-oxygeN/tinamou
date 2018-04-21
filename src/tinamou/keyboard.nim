## Keyboard Input

import
  sdl2

type
  TKeyName* {.pure.} = enum
    KEYA, KEYB, KEYC, KEYD, KEYE, KEYF, KEYG, KEYH, KEYI, KEYJ, KEYK, KEYL, KEYM,
    KEYN, KEYO, KEYP, KEYQ, KEYR, KEYS, KEYT, KEYU, KEYV, KEYW, KEYX, KEYY, KEYZ,
    DIGIT0, DIGIT1, DIGIT2, DIGIT3, DIGIT4, DIGIT5, DIGIT6, DIGIT7, DIGIT8, DIGIT9,
    COMMA, PERIOD, SLASH, SEMICOLON, COLON, MINUS, AT, LEFTBRACKET, RIGHTBRACKET, UNDERSCORE,
    LEFT, UP, RIGHT, DOWN,
    ENTER, SPACE, SHIFT, BACKSPACE, ESCAPE, CTRL, ALT, META,
    F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12,
    UNKNOWN

  TDetailedKeyState = enum
    up = 0, down, pressed, released

  TKeyboard* = ref object of RootObj
    keyStates: array[TKeyName, TDetailedKeyState]

proc toKeyName(keyCode: cint): TKeyName =
  ## Convert key code to key name.
  result = case keyCode
    of K_a: TKeyName.KEYA
    of K_b: TKeyName.KEYB
    of K_c: TKeyName.KEYC
    of K_d: TKeyName.KEYD
    of K_e: TKeyName.KEYE
    of K_f: TKeyName.KEYF
    of K_g: TKeyName.KEYG
    of K_h: TKeyName.KEYH
    of K_i: TKeyName.KEYI
    of K_j: TKeyName.KEYJ
    of K_k: TKeyName.KEYK
    of K_l: TKeyName.KEYL
    of K_m: TKeyName.KEYM
    of K_n: TKeyName.KEYN
    of K_o: TKeyName.KEYO
    of K_p: TKeyName.KEYP
    of K_q: TKeyName.KEYQ
    of K_r: TKeyName.KEYR
    of K_s: TKeyName.KEYS
    of K_t: TKeyName.KEYT
    of K_u: TKeyName.KEYU
    of K_v: TKeyName.KEYV
    of K_w: TKeyName.KEYW
    of K_x: TKeyName.KEYX
    of K_y: TKeyName.KEYY
    of K_z: TKeyName.KEYZ
    of K_0, K_KP_0: TKeyName.DIGIT0
    of K_1, K_KP_1: TKeyName.DIGIT1
    of K_2, K_KP_2: TKeyName.DIGIT2
    of K_3, K_KP_3: TKeyName.DIGIT3
    of K_4, K_KP_4: TKeyName.DIGIT4
    of K_5, K_KP_5: TKeyName.DIGIT5
    of K_6, K_KP_6: TKeyName.DIGIT6
    of K_7, K_KP_7: TKeyName.DIGIT7
    of K_8, K_KP_8: TKeyName.DIGIT8
    of K_9, K_KP_9: TKeyName.DIGIT9
    of K_COMMA: TKeyName.COMMA
    of K_PERIOD: TKeyName.PERIOD
    of K_SLASH: TKeyName.SLASH
    of K_SEMICOLON: TKeyName.SEMICOLON
    of K_COLON: TKeyName.COLON
    of K_MINUS: TKeyName.MINUS
    of K_AT: TKeyName.AT
    of K_LEFTBRACKET: TKeyName.LEFTBRACKET
    of K_RIGHTBRACKET: TKeyName.RIGHTBRACKET
    of K_UNDERSCORE: TKeyName.UNDERSCORE
    of K_LEFT: TKeyName.LEFT
    of K_UP: TKeyName.UP
    of K_RIGHT: TKeyName.RIGHT
    of K_DOWN: TKeyName.DOWN
    of K_RETURN, K_RETURN2, K_KP_ENTER: TKeyName.ENTER
    of K_SPACE: TKeyName.SPACE
    of K_LSHIFT, K_RSHIFT: TKeyName.SHIFT
    of K_BACKSPACE: TKeyName.BACKSPACE
    of K_ESCAPE: TKeyName.ESCAPE
    of K_LCTRL, K_RCTRL: TKeyName.CTRL
    of K_LALT, K_RALT: TKeyName.ALT
    of K_LGUI, K_RGUI: TKeyName.META
    of K_F1: TKeyName.F1
    of K_F2: TKeyName.F2
    of K_F3: TKeyName.F3
    of K_F4: TKeyName.F4
    of K_F5: TKeyName.F5
    of K_F6: TKeyName.F6
    of K_F7: TKeyName.F7
    of K_F8: TKeyName.F8
    of K_F9: TKeyName.F9
    of K_F10: TKeyName.F10
    of K_F11: TKeyName.F11
    of K_F12: TKeyName.F12
    else: TKeyName.UNKNOWN

proc newKeyboard*(): TKeyboard =
  ## Create new keyboard.
  new result

proc isDown*(self: TKeyboard, keyNames: varargs[TKeyName]): bool =
  ## Check if any key of key names is down or pressed now.
  result = false
  for keyName in keyNames:
    if self.keyStates[keyName] == down or self.keyStates[keyName] == pressed: return true

proc isPressed*(self: TKeyboard, keyNames: varargs[TKeyName]): bool =
  ## Check if any key of key names is now pressed.
  result = false
  for keyname in keyNames:
    if self.keyStates[keyName] == pressed: return true

proc isReleased*(self: TKeyboard, keyNames: varargs[TKeyName]): bool =
  ## Check if any key of keynames is now released.
  result = false
  for keyName in keyNames:
    if self.keyStates[keyName] == released: return true

proc update*(self: TKeyboard, event: Event) =
  ## Update keyboard state by event.
  case event.kind
  of KeyDown:
    if not self.isDown(event.key.keysym.sym.toKeyName):
      self.keyStates[event.key.keysym.sym.toKeyName] = pressed
  of KeyUp:
    self.keyStates[event.key.keysym.sym.toKeyName] = released
  else:
    discard

proc frameEnd*(self: TKeyboard) =
  ## Tell keyboard the end of a frame.
  for keyName in TKeyName:
    if self.keyStates[keyName] == pressed:
      self.keyStates[keyName] = down
    elif self.keyStates[keyName] == released:
      self.keyStates[keyName] = up

proc getPressingKeyNames*(self: TKeyboard): seq[TKeyName] =
  ## Get pressing key names.
  for keyName in TKeyName:
    if self.isPressed keyName: result.safeAdd keyName
