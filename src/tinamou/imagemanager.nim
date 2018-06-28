## Image Manager

import
  tables,

  sdl2,
  sdl2.image,

  exception

type
  ImageKind = enum
    source, sprite

  Image* = ref object of RootObj
    src: string
    texture: TexturePtr
    width*, height*: int
    case kind: ImageKind
    of sprite:
      spriteWidth, spriteHeight: int
      spriteColumns: int
    of source:
      discard

  ImageManager* = ref object of RootObj
    table: TableRef[string, Image]
    renderer: RendererPtr

proc newImage(renderer: RendererPtr, path: static[string]): Image =
  ## Create new image.
  new result
  result.src = path

  let surface = image.load(path)
  if surface.isNil: raise newTinamouException(IMAGE_LOAD_ERROR_CODE, "Image " & path & " could not be loaded. " & $sdl2.getError())
  defer: freeSurface surface

  result.texture = renderer.createTextureFromSurface(surface)
  result.width = surface.w
  result.height = surface.h
  result.kind = source

proc newImageFromRW(renderer: RendererPtr, src: RWopsPtr): Image =
  ## Create new image from data.
  new result
  result.src = "#!EMBEDDED"

  let surface = image.load_RW(src, 1)
  if surface.isNil: raise newTinamouException(IMAGE_LOAD_ERROR_CODE, "Image could not be loaded. " & $sdl2.getError())
  defer: freeSurface surface

  result.texture = renderer.createTextureFromSurface(surface)
  result.width = surface.w
  result.height = surface.h
  result.kind = source

proc newSprite(renderer: RendererPtr, path: static[string], spriteWidth, spriteHeight: static[int]): Image =
  ## Create new sprite.
  new result
  result.src = path

  let surface = image.load(path)
  if surface.isNil: raise newTinamouException(IMAGE_LOAD_ERROR_CODE, "Image " & path & " could not be loaded. " & $sdl2.getError())
  defer: freeSurface surface

  result.texture = renderer.createTextureFromSurface(surface)
  result.width = spriteWidth
  result.height = spriteHeight
  result.kind = sprite
  result.spriteWidth = spriteWidth
  result.spriteHeight = spriteHeight
  result.spriteColumns = surface.w div spriteWidth

proc newSpriteFromRW(renderer: RendererPtr, src: RWopsPtr, spriteWidth, spriteHeight: static[int]): Image =
  ## Create new sprite from data.
  new result
  result.src = "#!EMBEDDED"

  let surface = image.load_RW(src, 1)
  if surface.isNil: raise newTinamouException(IMAGE_LOAD_ERROR_CODE, "Image could not be loaded. " & $sdl2.getError())
  defer: freeSurface surface

  result.texture = renderer.createTextureFromSurface(surface)
  result.width = spriteWidth
  result.height = spriteHeight
  result.kind = sprite
  result.spriteWidth = spriteWidth
  result.spriteHeight = spriteHeight
  result.spriteColumns = surface.w div spriteWidth

proc getSrc*(self: Image): string = self.src
proc getTexture*(self: Image): TexturePtr = self.texture
proc isSprite*(self: Image): bool = self.kind == sprite
proc getSpriteSize*(self: Image): tuple[width, height, columns: int] =
  if self.kind == sprite:
    (width: self.spriteWidth, height: self.spriteHeight, columns: self.spriteColumns)
  else:
    (width: self.width, height: self.height, columns: 0)

proc destroy(self: Image) =
  ## Free image resources.
  destroy self.texture

proc newImageManager*(renderer: RendererPtr): ImageManager =
  ## Create new image manager.
  new result
  result.renderer = renderer
  result.table = newTable[string, Image]()

proc setImage*(self: ImageManager; name, path: static[string]): ImageManager {.discardable.} =
  ## Set an image.
  if not self.table.hasKey(name):
    self.table.add(name, newImage(self.renderer, path))

proc setImage*(self: ImageManager, name: static[string], src: RWopsPtr): ImageManager {.discardable.} =
  ## Set an image from embedded data.
  if not self.table.hasKey(name):
    self.table.add(name, newImageFromRW(self.renderer, src))

proc setSprite*(self: ImageManager; name, path: static[string]; spriteWidth, spriteHeight: static[int]): ImageManager {.discardable.} =
  ## Set a sprite image.
  if not self.table.hasKey(name):
    self.table.add(name, newSprite(self.renderer, path, spriteWidth, spriteHeight))

proc setSprite*(self: ImageManager; name: static[string]; src: RWopsPtr, spriteWidth, spriteHeight: static[int]): ImageManager {.discardable.} =
  ## Set a sprite image from embedded data.
  if not self.table.hasKey(name):
    self.table.add(name, newSpriteFromRW(self.renderer, src, spriteWidth, spriteHeight))

proc getImage*(self: ImageManager; name: string): Image =
  ## Get an image.
  if self.table.hasKey(name):
    return self.table[name]
  else:
    raise newTinamouException(IMAGE_NOT_FOUND_ERROR_CODE, "Image '" & name & "' was not registered.")

proc destroy*(self: ImageManager) =
  ## Free image manager resources.
  for image in self.table.values:
    destroy image

  clear self.table
