## Image Manager

import
  tables,

  sdl2,
  sdl2.image,

  exception

type
  TImageKind = enum
    source, sprite

  TImage* = ref object of RootObj
    src: string
    texture: TexturePtr
    width*, height*: int
    case kind: TImageKind
    of sprite:
      spriteWidth, spriteHeight: int
      spriteColumns: int
    of source:
      discard

  TImageManager* = ref object of RootObj
    table: TableRef[string, TImage]
    renderer: RendererPtr

proc newImage(renderer: RendererPtr, path: static[string]): TImage =
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

proc newImageFromRW(renderer: RendererPtr, src: RWopsPtr): TImage =
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

proc newSprite(renderer: RendererPtr, path: static[string], spriteWidth, spriteHeight: static[int]): TImage =
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

proc newSpriteFromRW(renderer: RendererPtr, src: RWopsPtr, spriteWidth, spriteHeight: static[int]): TImage =
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

proc getSrc*(self: TImage): string = self.src
proc getTexture*(self: TImage): TexturePtr = self.texture
proc isSprite*(self: TImage): bool = self.kind == sprite
proc getSpriteSize*(self: TImage): tuple[width, height, columns: int] =
  if self.kind == sprite:
    (width: self.spriteWidth, height: self.spriteHeight, columns: self.spriteColumns)
  else:
    (width: self.width, height: self.height, columns: 0)

proc destroy(self: TImage) =
  ## Free image resources.
  destroy self.texture

proc newImageManager*(renderer: RendererPtr): TImageManager =
  ## Create new image manager.
  new result
  result.renderer = renderer
  result.table = newTable[string, TImage]()

proc setImage*(self: TImageManager; name, path: static[string]): TImageManager {.discardable.} =
  ## Set an image.
  if not self.table.hasKey(name):
    self.table.add(name, newImage(self.renderer, path))

proc setImage*(self: TImageManager, name: static[string], src: RWopsPtr): TImageManager {.discardable.} =
  ## Set an image from embedded data.
  if not self.table.hasKey(name):
    self.table.add(name, newImageFromRW(self.renderer, src))

proc setSprite*(self: TImageManager; name, path: static[string]; spriteWidth, spriteHeight: static[int]): TImageManager {.discardable.} =
  ## Set a sprite image.
  if not self.table.hasKey(name):
    self.table.add(name, newSprite(self.renderer, path, spriteWidth, spriteHeight))

proc setSprite*(self: TImageManager; name: static[string]; src: RWopsPtr, spriteWidth, spriteHeight: static[int]): TImageManager {.discardable.} =
  ## Set a sprite image from embedded data.
  if not self.table.hasKey(name):
    self.table.add(name, newSpriteFromRW(self.renderer, src, spriteWidth, spriteHeight))

proc getImage*(self: TImageManager; name: string): TImage =
  ## Get an image.
  if self.table.hasKey(name):
    return self.table[name]
  else:
    raise newTinamouException(IMAGE_NOT_FOUND_ERROR_CODE, "Image '" & name & "' was not registered.")

proc destroy*(self: TImageManager) =
  ## Free image manager resources.
  for image in self.table.values:
    destroy image

  clear self.table
