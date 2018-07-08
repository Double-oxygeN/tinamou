## Exception Handling

type
  ErrorCode = distinct range[1000..9999]

  TinamouException* = object of Exception
    errorCode: ErrorCode

proc `$`*(errorCode: ErrorCode): string {.borrow.}

template newTinamouException*(code: ErrorCode, message: string): untyped =
  var
    e: ref TinamouException
  e = TinamouException.newException(message & " (Error Code: " & $code & ")")
  e.errorCode = code
  if e.isNil: assert false
  e

proc getErrorCode*(self: TinamouException): ErrorCode = self.errorCode
proc getErrorCode*(self: ref TinamouException): ErrorCode = self.errorCode

const
  # 10xx: SDL2 Error
  INIT_ERROR_CODE* = 1001.ErrorCode
  INIT_TEXTURE_FILTERING_ERROR_CODE* = 1002.ErrorCode
  WINDOW_CREATION_ERROR_CODE* = 1003.ErrorCode
  RENDERER_CREATION_ERROR_CODE* = 1004.ErrorCode
  RENDERER_CONFIG_ERROR_CODE* = 1005.ErrorCode
  FULLSCREEN_ERROR* = 1006.ErrorCode

  # 15xx: Font Error
  FONT_LOAD_ERROR_CODE* = 1501.ErrorCode

  # 16xx: Image Error
  IMAGE_LOAD_ERROR_CODE* = 1601.ErrorCode

  # 17xx: Sound Error
  BGM_LOAD_ERROR_CODE* = 1701.ErrorCode
  SE_LOAD_ERROR_CODE* = 1702.ErrorCode
  BGM_PLAY_ERROR_CODE* = 1711.ErrorCode
  SE_PLAY_ERROR_CODE* = 1712.ErrorCode

  # 18xx: Implementation Error
  UNKNOWN_TRANSITION_ERROR_CODE* = 1801.ErrorCode
  SCENE_NOT_FOUND_ERROR_CODE* = 1802.ErrorCode
  INVALID_TRANSITION_ERROR_CODE* = 1803.ErrorCode
  FONT_NOT_FOUND_ERROR_CODE* = 1851.ErrorCode
  FONT_NEVER_SET_ERROR_CODE* = 1852.ErrorCode
  IMAGE_NOT_FOUND_ERROR_CODE* = 1861.ErrorCode
  BGM_NOT_FOUND_ERROR_CODE* = 1871.ErrorCode
  SE_NOT_FOUND_ERROR_CODE* = 1872.ErrorCode
