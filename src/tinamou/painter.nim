## Painter

import
  colors,
  math,

  sdl2,
  sdl2.gfx,
  sdl2.image,
  sdl2.ttf,

  imagemanager,
  exception

type
  Painter* = ref object of RootObj
    renderer: RendererPtr
    font: FontPtr
    fontPath: string
    fontSize: int

  OriginKind* {.pure.} = enum
    NW = 0, N, NE, W, C, E, SW, S, SE

  PaintableRect* = ref object of RootObj
    renderer: RendererPtr
    x, y, w, h: int16

  PaintableRoundRect* = ref object of PaintableRect
    radius: int16

  PaintableLine* = ref object of RootObj
    renderer: RendererPtr
    x0, x1, y0, y1: int16

  PaintableThickLine* = ref object of PaintableLine
    width: uint8

  PaintableCircle* = ref object of RootObj
    renderer: RendererPtr
    x, y, radius: int16

  PaintableArc* = ref object of PaintableCircle
    start, finish: int16

  PaintableEllipse* = ref object of RootObj
    renderer: RendererPtr
    x, y, rx, ry: int16

  PaintablePie* = ref object of PaintableCircle
    start, finish: int16

  PaintablePolygon*[N: static[int]] = ref object of RootObj
    renderer: RendererPtr
    xs, ys: array[N, int16]

  PaintableBezier*[N: static[int]] = ref object of RootObj
    renderer: RendererPtr
    xs, ys: array[N, int16]
    steps: cint

  PaintableText* = ref object of RootObj
    renderer: RendererPtr
    font: FontPtr
    x, y: int16
    str: string
    origin: OriginKind

  RGBAFillable = concept x
    x.fill(r = uint8, g = uint8, b = uint8, alpha = uint8)

  RGBAStrokeable = concept x
    x.stroke(r = uint8, g = uint8, b = uint8, alpha = uint8)

proc toInt16(n: SomeInteger): int16 = n.int16
proc toInt16(n: SomeReal): int16 = n.toInt.int16

proc getOrigin[N0, N1: SomeNumber](origin: OriginKind, x, y: N0; width, height: N1): tuple[x, y: float] =
  case origin
  of OriginKind.NW, OriginKind.W, OriginKind.SW: result.x = x.float
  of OriginKind.N, OriginKind.C, OriginKind.S: result.x = x.float - width / 2
  of OriginKind.NE, OriginKind.E, OriginKind.SE: result.x = x.float - width.float

  case origin
  of OriginKind.NW, OriginKind.N, OriginKind.NE: result.y = y.float
  of OriginKind.W, OriginKind.C, OriginKind.E: result.y = y.float - height / 2
  of OriginKind.SW, OriginKind.S, OriginKind.SE: result.y = y.float - height.float

proc newTPainter*(renderer: RendererPtr): Painter =
  ## Create new painter from given renderer.
  new result
  result.renderer = renderer
  result.font = nil
  result.fontPath = ""
  result.fontSize = 20

proc clear*(self: Painter; r, g, b: uint8; alpha: uint8 = 255) =
  ## Clear the window.
  self.renderer.setDrawColor(r = r, g = g, b = b, a = alpha)
  self.renderer.clear()

proc clear*(self: Painter, color: colors.Color, alpha: uint8 = 255) =
  ## Clear the window.
  let
    rgb = color.extractRGB()
  self.clear(r = rgb.r, g = rgb.g, b = rgb.b, alpha = alpha)

proc clear*(self: Painter, color: sdl2.Color) =
  ## Clear the window.
  self.renderer.setDrawColor(color)
  self.renderer.clear()

proc drawImage0(self: Painter, image: Image, srcRect: ptr Rect = nil, dstRect: ptr Rect, spriteNum: int, alpha: uint8) =
  ## Draw image.
  image.getTexture().setTextureAlphaMod(alpha)

  if image.isSprite:
    let
      spriteSize = image.getSpriteSize()
      origin: tuple[x, y: int] = (x: spriteSize.width * (spriteNum mod spriteSize.columns), y: spriteSize.height * (spriteNum div spriteSize.columns))
    var
      actualSrcRect: Rect = if srcRect.isNil:
          (x: origin.x.cint, y: origin.y.cint, w: spriteSize.width.cint, h: spriteSize.height.cint)
        else:
          (x: (origin.x + srcRect.x).cint, y: (origin.y + srcRect.y).cint, w: (spriteSize.width - srcRect.x).cint, h: (spriteSize.height - srcRect.y).cint)

    self.renderer.copy(image.getTexture(), addr actualSrcRect, dstRect)

  else:
    self.renderer.copy(image.getTexture(), srcRect, dstRect)

proc drawImage*[N: SomeNumber](self: Painter, image: Image; x, y: N; spriteNum: int = 0; alpha: uint8 = 255; origin: OriginKind = OriginKind.NW; fixRatio: bool = false) =
  ## Draw image.
  let originPos: tuple[x, y: float] = origin.getOrigin(x, y, image.width, image.height)
  var dstRect: Rect = (x: originPos.x.toInt.cint, y: originPos.y.toInt.cint, w: image.width.cint, h: image.height.cint)

  self.drawImage0(image = image, dstRect = addr dstRect, spriteNum = spriteNum, alpha = alpha)

proc drawImage*[N0, N1: SomeNumber](self: Painter, image: Image; x, y: N0; width, height: N1; spriteNum: int = 0; alpha: uint8 = 255; origin: OriginKind = OriginKind.NW; fixRatio: bool = false) =
  ## Draw image.
  var dstRect: Rect

  if fixRatio:
    let
      zoom: float = min(width / image.width, height / image.height)
      actualWidth: float = zoom * image.width.float
      actualHeight: float = zoom * image.height.float
      originPos: tuple[x, y: float] = origin.getOrigin(x, y, actualWidth, actualHeight)
    dstRect = (x: originPos.x.toInt.cint, y: originPos.y.toInt.cint, w: actualWidth.toInt.cint, h: actualHeight.toInt.cint)
  else:
    let originPos: tuple[x, y: float] = origin.getOrigin(x, y, width, height)
    dstRect = (x: originPos.x.toInt.cint, y: originPos.y.toInt.cint, w: width.toInt16.cint, h: height.toInt16.cint)

  self.drawImage0(image = image, dstRect = addr dstRect, spriteNum = spriteNum, alpha = alpha)

proc drawImage*[N0, N1, N2, N3: SomeNumber](self: Painter, image: Image; srcX, srcY: N0; srcWidth, srcHeight: N1; x, y: N2; width, height: N3; spriteNum: int = 0; alpha: uint8 = 255; origin: OriginKind = OriginKind.NW; fixRatio: bool = false) =
  ## Draw image.
  let
    actualSrcWidth: float = min(srcWidth.float, image.width.float - srcX.float)
    actualSrcHeight: float = min(srcHeight.float, image.height.float - srcY.float)
  var
    srcRect: Rect = (x: srcX.toInt16.cint, y: srcY.toInt16.cint, w: actualSrcWidth.toInt.cint, h: actualSrcHeight.toInt.cint)
    dstRect: Rect

  if fixRatio:
    let
      zoom: float = min(width / srcWidth, height / srcHeight)
      actualWidth: float = zoom * actualSrcWidth
      actualHeight: float = zoom * actualSrcHeight
      originPos: tuple[x, y: float] = origin.getOrigin(x, y, zoom * srcWidth.float, zoom * srcHeight.float)
    dstRect = (x: originPos.x.toInt.cint, y: originPos.y.toInt.cint, w: actualWidth.toInt.cint, h: actualHeight.toInt.cint)
  else:
    let
      actualWidth: float = width.float * (actualSrcWidth / srcWidth.float)
      actualHeight: float = height.float * (actualSrcHeight / srcHeight.float)
      originPos: tuple[x, y: float] = origin.getOrigin(x, y, width, height)
    dstRect = (x: originPos.x.toInt.cint, y: originPos.y.toInt.cint, w: actualWidth.toInt.cint, h: actualHeight.toInt.cint)

  self.drawImage0(image = image, srcRect = addr srcRect, dstRect = addr dstRect, spriteNum = spriteNum, alpha = alpha)

proc rect*[N0, N1: SomeNumber](self: Painter; x, y: N0; w, h: N1): PaintableRect =
  ## Create paintable rectangle.
  new result
  result.renderer = self.renderer
  result.x = x.toInt16
  result.y = y.toInt16
  result.w = w.toInt16
  result.h = h.toInt16

proc roundRect*[N0, N1, N2: SomeNumber](self: Painter; x, y: N0; w, h: N1; radius: N2): PaintableRoundRect =
  ## Create paintable round rectangle.
  new result
  result.renderer = self.renderer
  result.x = x.toInt16
  result.y = y.toInt16
  result.w = w.toInt16
  result.h = h.toInt16
  result.radius = radius.toInt16

proc line*[N: SomeNumber](self: Painter; x0, y0, x1, y1: N): PaintableLine =
  ## Create paintable line.
  new result
  result.renderer = self.renderer
  result.x0 = x0.toInt16
  result.y0 = y0.toInt16
  result.x1 = x1.toInt16
  result.y1 = y1.toInt16

proc thickLine*[N: SomeNumber](self: Painter; x0, y0, x1, y1: N; width: uint8): PaintableThickLine =
  ## Create paintable thick line.
  new result
  result.renderer = self.renderer
  result.x0 = x0.toInt16
  result.y0 = y0.toInt16
  result.x1 = x1.toInt16
  result.y1 = y1.toInt16
  result.width = width

proc circle*[N0, N1: SomeNumber](self: Painter; x, y: N0; radius: N1): PaintableCircle =
  ## Create paintable circle.
  new result
  result.renderer = self.renderer
  result.x = x.toInt16
  result.y = y.toInt16
  result.radius = radius.toInt16

proc arc*[N0, N1, N2: SomeNumber](self: Painter; x, y: N0; radius: N1; start, finish: N2): PaintableArc =
  ## Create paintable arc.
  new result
  result.renderer = self.renderer
  result.x = x.toInt16
  result.y = y.toInt16
  result.radius = radius.toInt16
  result.start = start.toInt16
  result.finish = finish.toInt16

proc ellipse*[N: SomeNumber](self: Painter; x, y, rx, ry: N): PaintableEllipse =
  ## Create paintable ellipse.
  new result
  result.renderer = self.renderer
  result.x = x.toInt16
  result.y = y.toInt16
  result.rx = rx.toInt16
  result.ry = ry.toInt16

proc pie*[N0, N1, N2: SomeNumber](self: Painter; x, y: N0; radius: N1; start, finish: N2): PaintablePie =
  ## Create paintable pie.
  new result
  result.renderer = self.renderer
  result.x = x.toInt16
  result.y = y.toInt16
  result.radius = radius.toInt16
  result.start = start.toInt16
  result.finish = finish.toInt16

proc polygon*[N: static[int], T: SomeNumber](self: Painter; xs, ys: array[N, T]): PaintablePolygon[N] =
  ## Create paintable polygon.
  new result
  result.renderer = self.renderer
  for i in 0..<N:
    result.xs[i] = xs[i].toInt16
    result.ys[i] = ys[i].toInt16

proc bezier*[N: static[int], T: SomeNumber](self: Painter, xs, ys: array[N, T]): PaintableBezier[N] =
  ## Create paintable bezier curve.
  new result
  result.renderer = self.renderer
  for i in 0..<N:
    result.xs[i] = xs[i].toInt16
    result.ys[i] = ys[i].toInt16

proc text*[N: SomeNumber](self: Painter, str: string; x, y: N; origin: OriginKind = OriginKind.SW): PaintableText =
  ## Create paintable text.
  new result
  result.renderer = self.renderer
  result.str = str
  result.font = self.font
  result.x = x.toInt16
  result.y = y.toInt16
  result.origin = origin

proc setFont*(self: Painter, fontPath: string, fontSize: int) =
  ## Set font from path.
  ## If loading fails, then raise an error.
  if ttfWasInit():
    if (fontPath != self.fontPath) or (fontSize != self.fontSize):
      if not self.font.isNil:
        ttf.close self.font

      self.font = openFont(fontPath, fontSize.cint)
      if self.font.isNil:
        raise newTinamouException(FONT_LOAD_ERROR_CODE, "Failed loading font " & fontPath & ".")

      self.fontPath = fontPath
      self.fontSize = fontSize

  else:
    raise newTinamouException(INIT_ERROR_CODE, "SDL2_TTF was not initialized.")

proc getFontPath*(self: Painter): string =
  ## Get current font path.
  return self.fontPath

proc stroke*(self: PaintableRect; r, g, b: uint8, alpha: uint8 = 255) =
  ## Stroke rectangle.
  self.renderer.rectangleRGBA(x1 = self.x, y1 = self.y, x2 = self.x + self.w, y2 = self.y + self.h, r = r, g = g, b = b, a = alpha)

proc stroke*(self: PaintableRoundRect; r, g, b: uint8, alpha: uint8 = 255) =
  ## Stroke round rectangle.
  self.renderer.roundedRectangleRGBA(x1 = self.x, y1 = self.y, x2 = self.x + self.w, y2 = self.y + self.h, rad = self.radius, r = r, g = g, b = b, a = alpha)

proc stroke*(self: PaintableLine; r, g, b: uint8, alpha: uint8 = 255, antialias: bool = false) =
  ## Stroke line.
  if self.y0 == self.y1:
    self.renderer.hlineRGBA(x1 = self.x0, x2 = self.x1, y = self.y0, r = r, g = g, b = b, a = alpha)
  elif self.x0 == self.x1:
    self.renderer.vlineRGBA(x = self.x0, y1 = self.y0, y2 = self.y1, r = r, g = g, b = b, a = alpha)
  elif antialias:
    self.renderer.aalineRGBA(x1 = self.x0, y1 = self.y0, x2 = self.x1, y2 = self.y1, r = r, g = g, b = b, a = alpha)
  else:
    self.renderer.lineRGBA(x1 = self.x0, y1 = self.y0, x2 = self.x1, y2 = self.y1, r = r, g = g, b = b, a = alpha)

proc stroke*(self: PaintableThickLine; r, g, b: uint8, alpha: uint8 = 255) =
  ## Stroke thick line.
  self.renderer.thickLineRGBA(x1 = self.x0, y1 = self.y0, x2 = self.x1, y2 = self.y1, width = self.width, r = r, g = g, b = b, a = alpha)

proc stroke*(self: PaintableCircle; r, g, b: uint8, alpha: uint8 = 255) =
  ## Stroke circle.
  self.renderer.circleRGBA(x = self.x, y = self.y, rad = self.radius, r = r, g = g, b = b, a = alpha)

proc stroke*(self: PaintableEllipse; r, g, b: uint8, alpha: uint8 = 255) =
  ## Stroke ellipse.
  self.renderer.ellipseRGBA(x = self.x, y = self.y, rx = self.rx, ry = self.ry, r = r, g = g, b = b, a = alpha)

proc stroke*(self: PaintablePie; r, g, b: uint8, alpha: uint8 = 255) =
  ## Stroke pie.
  self.renderer.pieRGBA(x = self.x, y = self.y, rad = self.radius, start = self.start, finish = self.finish, r = r, g = g, b = b, a = alpha)

proc stroke*[N: static[int]](self: PaintablePolygon[N]; r, g, b: uint8, alpha: uint8 = 255) =
  ## Stroke polygon
  when N == 3:
    self.renderer.trigonRGBA(x1 = self.xs[0], y1 = self.ys[0], x2 = self.xs[1], y2 = self.ys[1], x3 = self.xs[2], y3 = self.ys[2], r = r, g = g, b = b, a = alpha)
  else:
    self.renderer.polygonRGBA(vx = cast[ptr int16](addr self.xs), vy = cast[ptr int16](addr self.ys), n = self.xs.len.cint, r = r, g = g, b = b, a = alpha)

proc stroke*[N: static[int]](self: PaintableBezier[N]; r, g, b: uint8, alpha: uint8 = 255) =
  ## Stroke bezier curve.
  when N == 2:
    self.renderer.lineRGBA(x1 = self.xs[0], y1 = self.ys[0], x2 = self.xs[1], y2 = self.ys[1], r = r, g = g, b = b, a = alpha)
  else:
    self.renderer.bezierRGBA(vx = cast[ptr int16](addr self.xs), vy = cast[ptr int16](addr self.ys), n = self.xs.len.cint, s = 48, r = r, g = g, b = b, a = alpha)

proc stroke*(self: RGBAStrokeable, color: colors.Color, alpha: uint8 = 255) =
  ## Stroke shape.
  let rgb = color.extractRGB()
  self.stroke(r = rgb.r, g = rgb.g, b = rgb.b, alpha = alpha)

proc stroke*(self: PaintableLine, color: colors.Color, alpha: uint8 = 255, antialias: bool = false) =
  ## Stroke line.
  let rgb = color.extractRGB()
  self.stroke(r = rgb.r, g = rgb.g, b = rgb.b, alpha = alpha, antialias = antialias)

proc fill*(self: PaintableRect; r, g, b: uint8, alpha: uint8 = 255) =
  ## Fill rectangle.
  self.renderer.boxRGBA(x1 = self.x, y1 = self.y, x2 = self.x + self.w, y2 = self.y + self.h, r = r, g = g, b = b, a = alpha)

proc fill*(self: PaintableRoundRect; r, g, b: uint8, alpha: uint8 = 255) =
  ## Fill round rectangle.
  self.renderer.roundedBoxRGBA(x1 = self.x, y1 = self.y, x2 = self.x + self.w, y2 = self.y + self.h, rad = self.radius, r = r, g = g, b = b, a = alpha)

proc fill*(self: PaintableCircle; r, g, b: uint8, alpha: uint8 = 255) =
  ## Fill circle.
  self.renderer.filledCircleRGBA(x = self.x, y = self.y, rad = self.radius, r = r, g = g, b = b, a = alpha)

proc fill*(self: PaintableEllipse; r, g, b: uint8, alpha: uint8 = 255) =
  ## Fill ellipse.
  self.renderer.filledEllipseRGBA(x = self.x, y = self.y, rx = self.rx, ry = self.ry, r = r, g = g, b = b, a = alpha)

proc fill*(self: PaintablePie; r, g, b: uint8, alpha: uint8 = 255) =
  ## Fill pie.
  self.renderer.filledPieRGBA(x = self.x, y = self.y, rad = self.radius, start = self.start, finish = self.finish, r = r, g = g, b = b, a = alpha)

proc fill*[N: static[int]](self: PaintablePolygon[N]; r, g, b: uint8, alpha: uint8 = 255) =
  ## Fill polygon.
  when N == 3:
    self.renderer.filledTrigonRGBA(x1 = self.xs[0], y1 = self.ys[0], x2 = self.xs[1], y2 = self.ys[1], x3 = self.xs[2], y3 = self.ys[2], r = r, g = g, b = b, a = alpha)
  else:
    self.renderer.filledPolygonRGBA(vx = cast[ptr int16](addr self.xs), vy = cast[ptr int16](addr self.ys), n = self.xs.len.cint, r = r, g = g, b = b, a = alpha)

proc fill*(self: PaintableText; r, g, b: uint8, alpha: uint8 = 255) =
  ## Fill text.
  let
    color: sdl2.Color = (r: r, g: g, b: b, a: alpha)
    surface: SurfacePtr = self.font.renderUTF8Solid(text = self.str, fg = color)
    texture = self.renderer.createTextureFromSurface(surface)
  defer: freeSurface surface

  var textureWidth, textureHeight: cint
  texture.queryTexture(nil, nil, addr textureWidth, addr textureHeight)
  let originPos: tuple[x, y: float] = self.origin.getOrigin(self.x.int, self.y.int, textureWidth.int, textureHeight.int)
  var dstRect: Rect = (x: originPos.x.toInt.cint, y: originPos.y.toInt.cint, w: textureWidth, h: textureHeight)

  self.renderer.copy(texture, nil, addr dstRect)

  destroy texture

proc fill*(self: RGBAFillable, color: colors.Color, alpha: uint8 = 255) =
  ## Fill rectangle.
  let rgb = color.extractRGB()
  self.fill(r = rgb.r, g = rgb.g, b = rgb.b, alpha = alpha)

proc present*(self: Painter) =
  self.renderer.present()
