## Painter

import
  colors,

  sdl2,
  sdl2.gfx,
  sdl2.image,
  sdl2.ttf,

  imagemanager,
  exception

type
  TPainter* = ref object of RootObj
    renderer: RendererPtr
    font: FontPtr
    fontPath: string
    fontSize: int

  TPaintableRect* = ref object of RootObj
    renderer: RendererPtr
    x, y, w, h: int16

  TPaintableRoundRect* = ref object of TPaintableRect
    radius: int16

  TPaintableLine* = ref object of RootObj
    renderer: RendererPtr
    x0, x1, y0, y1: int16

  TPaintableThickLine* = ref object of TPaintableLine
    width: uint8

  TPaintableCircle* = ref object of RootObj
    renderer: RendererPtr
    x, y, radius: int16

  TPaintableArc* = ref object of TPaintableCircle
    start, finish: int16

  TPaintableEllipse* = ref object of RootObj
    renderer: RendererPtr
    x, y, rx, ry: int16

  TPaintablePie* = ref object of TPaintableCircle
    start, finish: int16

  TPaintablePolygon*[N: static[int]] = ref object of RootObj
    renderer: RendererPtr
    xs, ys: array[N, int16]

  TPaintableBezier*[N: static[int]] = ref object of RootObj
    renderer: RendererPtr
    xs, ys: array[N, int16]
    steps: cint

  TPaintableText* = ref object of RootObj
    renderer: RendererPtr
    font: FontPtr
    x, y: int16
    str: string

  RGBAFillable = concept x
    x.fill(r = uint8, g = uint8, b = uint8, alpha = uint8)

  RGBAStrokeable = concept x
    x.stroke(r = uint8, g = uint8, b = uint8, alpha = uint8)

proc toInt16(n: SomeInteger): int16 = n.int16
proc toInt16(n: SomeReal): int16 = n.toInt.int16

proc newTPainter*(renderer: RendererPtr): TPainter =
  ## Create new painter from given renderer.
  new result
  result.renderer = renderer
  result.font = nil
  result.fontPath = ""
  result.fontSize = 20

proc clear*(self: TPainter; r, g, b: uint8; alpha: uint8 = 255) =
  ## Clear the window.
  self.renderer.setDrawColor(r = r, g = g, b = b, a = alpha)
  self.renderer.clear()

proc clear*(self: TPainter, color: colors.Color, alpha: uint8 = 255) =
  ## Clear the window.
  let
    rgb = color.extractRGB()
  self.clear(r = rgb.r, g = rgb.g, b = rgb.b, alpha = alpha)

proc clear*(self: TPainter, color: sdl2.Color) =
  ## Clear the window.
  self.renderer.setDrawColor(color)
  self.renderer.clear()

proc drawImage(self: TPainter, image: TImage, srcRect: ptr Rect = nil, dstRect: ptr Rect, spriteNum: int = 0) =
  ## Draw image.
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

proc drawImage*(self: TPainter, image: TImage; x, y: SomeNumber; spriteNum: int = 0) =
  ## Draw image.
  var dstRect: Rect = (x: x.toInt16.cint, y: y.toInt16.cint, w: image.width.cint, h: image.height.cint)

  self.drawImage(image = image, dstRect = addr dstRect, spriteNum = spriteNum)

proc drawImage*(self: TPainter, image: TImage; x, y, width, height: SomeNumber; spriteNum: int = 0) =
  ## Draw image.
  var dstRect: Rect = (x: x.toInt16.cint, y: y.toInt16.cint, w: width.toInt16.cint, h: height.toInt16.cint)

  self.drawImage(image = image, dstRect = addr dstRect, spriteNum = spriteNum)

proc drawImage*(self: TPainter, image: TImage; srcX, srcY, srcWidth, srcHeight, x, y, width, height: SomeNumber; spriteNum: int = 0) =
  ## Draw image.
  var
    srcRect: Rect = (x: srcX.toInt16.cint, y: srcY.toInt16.cint, w: srcWidth.toInt16.cint, h: srcHeight.toInt16.cint)
    dstRect: Rect = (x: x.toInt16.cint, y: y.toInt16.cint, w: width.toInt16.cint, h: height.toInt16.cint)

  self.drawImage(image = image, srcRect = addr srcRect, dstRect = addr dstRect, spriteNum = spriteNum)

proc rect*(self: TPainter; x, y, w, h: SomeNumber): TPaintableRect =
  ## Create paintable rectangle.
  new result
  result.renderer = self.renderer
  result.x = x.toInt16
  result.y = y.toInt16
  result.w = w.toInt16
  result.h = h.toInt16

proc roundRect*(self: TPainter; x, y, w, h, radius: SomeNumber): TPaintableRoundRect =
  ## Create paintable round rectangle.
  new result
  result.renderer = self.renderer
  result.x = x.toInt16
  result.y = y.toInt16
  result.w = w.toInt16
  result.h = h.toInt16
  result.radius = radius.toInt16

proc line*(self: TPainter; x0, y0, x1, y1: SomeNumber): TPaintableLine =
  ## Create paintable line.
  new result
  result.renderer = self.renderer
  result.x0 = x0.toInt16
  result.y0 = y0.toInt16
  result.x1 = x1.toInt16
  result.y1 = y1.toInt16

proc thickLine*(self: TPainter; x0, y0, x1, y1: SomeNumber; width: uint8): TPaintableThickLine =
  ## Create paintable thick line.
  new result
  result.renderer = self.renderer
  result.x0 = x0.toInt16
  result.y0 = y0.toInt16
  result.x1 = x1.toInt16
  result.y1 = y1.toInt16
  result.width = width

proc circle*(self: TPainter; x, y, radius: SomeNumber): TPaintableCircle =
  ## Create paintable circle.
  new result
  result.renderer = self.renderer
  result.x = x.toInt16
  result.y = y.toInt16
  result.radius = radius.toInt16

proc arc*(self: TPainter; x, y, radius, start, finish: SomeNumber): TPaintableArc =
  ## Create paintable arc.
  new result
  result.renderer = self.renderer
  result.x = x.toInt16
  result.y = y.toInt16
  result.radius = radius.toInt16
  result.start = start.toInt16
  result.finish = finish.toInt16

proc ellipse*(self: TPainter; x, y, rx, ry: SomeNumber): TPaintableEllipse =
  ## Create paintable ellipse.
  new result
  result.renderer = self.renderer
  result.x = x.toInt16
  result.y = y.toInt16
  result.rx = rx.toInt16
  result.ry = ry.toInt16

proc pie*(self: TPainter; x, y, radius, start, finish: SomeNumber): TPaintablePie =
  ## Create paintable pie.
  new result
  result.renderer = self.renderer
  result.x = x.toInt16
  result.y = y.toInt16
  result.radius = radius.toInt16
  result.start = start.toInt16
  result.finish = finish.toInt16

proc polygon*[N: static[int], T: SomeNumber](self: TPainter; xs, ys: array[N, T]): TPaintablePolygon[N] =
  ## Create paintable polygon.
  new result
  result.renderer = self.renderer
  for i in 0..<N:
    result.xs[i] = xs[i].toInt16
    result.ys[i] = ys[i].toInt16

proc bezier*[N: static[int], T: SomeNumber](self: TPainter, xs, ys: array[N, T]): TPaintableBezier[N] =
  ## Create paintable bezier curve.
  new result
  result.renderer = self.renderer
  for i in 0..<N:
    result.xs[i] = xs[i].toInt16
    result.ys[i] = ys[i].toInt16

proc text*(self: TPainter, str: string; x, y: SomeNumber): TPaintableText =
  ## Create paintable text.
  new result
  result.renderer = self.renderer
  result.str = str
  result.font = self.font
  result.x = x.toInt16
  result.y = y.toInt16
  # result.textureHistory = newTable[uint32, TexturePtr]()

proc setFont*(self: TPainter, fontPath: string, fontSize: int) =
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

proc getFontPath*(self: TPainter): string =
  ## Get current font path.
  return self.fontPath

proc stroke*(self: TPaintableRect; r, g, b: uint8, alpha: uint8 = 255) =
  ## Stroke rectangle.
  self.renderer.rectangleRGBA(x1 = self.x, y1 = self.y, x2 = self.x + self.w, y2 = self.y + self.h, r = r, g = g, b = b, a = alpha)

proc stroke*(self: TPaintableRoundRect; r, g, b: uint8, alpha: uint8 = 255) =
  ## Stroke round rectangle.
  self.renderer.roundedRectangleRGBA(x1 = self.x, y1 = self.y, x2 = self.x + self.w, y2 = self.y + self.h, rad = self.radius, r = r, g = g, b = b, a = alpha)

proc stroke*(self: TPaintableLine; r, g, b: uint8, alpha: uint8 = 255, antialias: bool = false) =
  ## Stroke line.
  if self.y0 == self.y1:
    self.renderer.hlineRGBA(x1 = self.x0, x2 = self.x1, y = self.y0, r = r, g = g, b = b, a = alpha)
  elif self.x0 == self.x1:
    self.renderer.vlineRGBA(x = self.x0, y1 = self.y0, y2 = self.y1, r = r, g = g, b = b, a = alpha)
  elif antialias:
    self.renderer.aalineRGBA(x1 = self.x0, y1 = self.y0, x2 = self.x1, y2 = self.y1, r = r, g = g, b = b, a = alpha)
  else:
    self.renderer.lineRGBA(x1 = self.x0, y1 = self.y0, x2 = self.x1, y2 = self.y1, r = r, g = g, b = b, a = alpha)

proc stroke*(self: TPaintableThickLine; r, g, b: uint8, alpha: uint8 = 255) =
  ## Stroke thick line.
  self.renderer.thickLineRGBA(x1 = self.x0, y1 = self.y0, x2 = self.x1, y2 = self.y1, width = self.width, r = r, g = g, b = b, a = alpha)

proc stroke*(self: TPaintableCircle; r, g, b: uint8, alpha: uint8 = 255) =
  ## Stroke circle.
  self.renderer.circleRGBA(x = self.x, y = self.y, rad = self.radius, r = r, g = g, b = b, a = alpha)

proc stroke*(self: TPaintableEllipse; r, g, b: uint8, alpha: uint8 = 255) =
  ## Stroke ellipse.
  self.renderer.ellipseRGBA(x = self.x, y = self.y, rx = self.rx, ry = self.ry, r = r, g = g, b = b, a = alpha)

proc stroke*(self: TPaintablePie; r, g, b: uint8, alpha: uint8 = 255) =
  ## Stroke pie.
  self.renderer.pieRGBA(x = self.x, y = self.y, rad = self.radius, start = self.start, finish = self.finish, r = r, g = g, b = b, a = alpha)

proc stroke*[N: static[int]](self: TPaintablePolygon[N]; r, g, b: uint8, alpha: uint8 = 255) =
  ## Stroke polygon
  when N == 3:
    self.renderer.trigonRGBA(x1 = self.xs[0], y1 = self.ys[0], x2 = self.xs[1], y2 = self.ys[1], x3 = self.xs[2], y3 = self.ys[2], r = r, g = g, b = b, a = alpha)
  else:
    self.renderer.polygonRGBA(vx = cast[ptr int16](addr self.xs), vy = cast[ptr int16](addr self.ys), n = self.xs.len.cint, r = r, g = g, b = b, a = alpha)

proc stroke*[N: static[int]](self: TPaintableBezier[N]; r, g, b: uint8, alpha: uint8 = 255) =
  ## Stroke bezier curve.
  when N == 2:
    self.renderer.lineRGBA(x1 = self.xs[0], y1 = self.ys[0], x2 = self.xs[1], y2 = self.ys[1], r = r, g = g, b = b, a = alpha)
  else:
    self.renderer.bezierRGBA(vx = cast[ptr int16](addr self.xs), vy = cast[ptr int16](addr self.ys), n = self.xs.len.cint, s = 48, r = r, g = g, b = b, a = alpha)

proc stroke*(self: RGBAStrokeable, color: colors.Color, alpha: uint8 = 255) =
  ## Stroke shape.
  let rgb = color.extractRGB()
  self.stroke(r = rgb.r, g = rgb.g, b = rgb.b, alpha = alpha)

proc stroke*(self: TPaintableLine, color: colors.Color, alpha: uint8 = 255, antialias: bool = false) =
  ## Stroke line.
  let rgb = color.extractRGB()
  self.stroke(r = rgb.r, g = rgb.g, b = rgb.b, alpha = alpha, antialias = antialias)

proc fill*(self: TPaintableRect; r, g, b: uint8, alpha: uint8 = 255) =
  ## Fill rectangle.
  self.renderer.boxRGBA(x1 = self.x, y1 = self.y, x2 = self.x + self.w, y2 = self.y + self.h, r = r, g = g, b = b, a = alpha)

proc fill*(self: TPaintableRoundRect; r, g, b: uint8, alpha: uint8 = 255) =
  ## Fill round rectangle.
  self.renderer.roundedBoxRGBA(x1 = self.x, y1 = self.y, x2 = self.x + self.w, y2 = self.y + self.h, rad = self.radius, r = r, g = g, b = b, a = alpha)

proc fill*(self: TPaintableCircle; r, g, b: uint8, alpha: uint8 = 255) =
  ## Fill circle.
  self.renderer.filledCircleRGBA(x = self.x, y = self.y, rad = self.radius, r = r, g = g, b = b, a = alpha)

proc fill*(self: TPaintableEllipse; r, g, b: uint8, alpha: uint8 = 255) =
  ## Fill ellipse.
  self.renderer.filledEllipseRGBA(x = self.x, y = self.y, rx = self.rx, ry = self.ry, r = r, g = g, b = b, a = alpha)

proc fill*(self: TPaintablePie; r, g, b: uint8, alpha: uint8 = 255) =
  ## Fill pie.
  self.renderer.filledPieRGBA(x = self.x, y = self.y, rad = self.radius, start = self.start, finish = self.finish, r = r, g = g, b = b, a = alpha)

proc fill*[N: static[int]](self: TPaintablePolygon[N]; r, g, b: uint8, alpha: uint8 = 255) =
  ## Fill polygon.
  when N == 3:
    self.renderer.filledTrigonRGBA(x1 = self.xs[0], y1 = self.ys[0], x2 = self.xs[1], y2 = self.ys[1], x3 = self.xs[2], y3 = self.ys[2], r = r, g = g, b = b, a = alpha)
  else:
    self.renderer.filledPolygonRGBA(vx = cast[ptr int16](addr self.xs), vy = cast[ptr int16](addr self.ys), n = self.xs.len.cint, r = r, g = g, b = b, a = alpha)

proc fill*(self: TPaintableText; r, g, b: uint8, alpha: uint8 = 255) =
  ## Fill text.
  let
    color: sdl2.Color = (r: r, g: g, b: b, a: alpha)
    surface: SurfacePtr = self.font.renderUTF8Solid(text = self.str, fg = color)
    texture = self.renderer.createTextureFromSurface(surface)
  defer: freeSurface surface

  var
    textureWidth, textureHeight: cint
  texture.queryTexture(nil, nil, addr textureWidth, addr textureHeight)
  var
    dstRect: Rect = (x: self.x.cint, y: self.y.cint, w: textureWidth, h: textureHeight)

  self.renderer.copy(texture, nil, addr dstRect)

  destroy texture

proc fill*(self: RGBAFillable, color: colors.Color, alpha: uint8 = 255) =
  ## Fill rectangle.
  let rgb = color.extractRGB()
  self.fill(r = rgb.r, g = rgb.g, b = rgb.b, alpha = alpha)

proc present*(self: TPainter) =
  self.renderer.present()
