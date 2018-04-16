## Sound Manager

import
  tables,

  sdl2,
  sdl2.mixer,

  exception

type
  TMusic* = ref object of RootObj
    src: string
    music: MusicPtr

  TSoundEffect* = ref object of RootObj
    src: string
    chunk: ChunkPtr

  TSoundManager* = ref object of RootObj
    bgms: TableRef[string, TMusic]
    ses: TableRef[string, TSoundEffect]

proc newMusic(path: static[string]): TMusic =
  ## Create new music.
  new result
  result.src = path
  result.music = loadMUS(path)

proc newMusicFromRW(src: RWopsPtr): TMusic =
  ## Create new music from data.
  new result
  result.src = "#!EMBEDDED"
  result.music = loadMUS_RW(src, 1)

proc play*(self: TMusic) =
  ## Play music.
  if playMusic(self.music, -1) < 0:
    raise newTinamouException(BGM_PLAY_ERROR_CODE, "Could not play music " & self.src & ". " & $sdl2.getError())

proc stopMusic*() =
  ## Stop background music.
  discard haltMusic()

proc newSoundEffect(path: static[string]): TSoundEffect =
  ## Create new sound effect.
  new result
  result.src = path
  result.chunk = loadWAV(path)

proc newSoundEffectFromRW(src: RWopsPtr): TSoundEffect =
  ## Create new sound effect from data.
  new result
  result.src = "#!EMBEDDED"
  result.chunk = loadWAV_RW(src, 1)

proc play*(self: TSoundEffect) =
  ## Play sound.
  if playChannel(-1, self.chunk, 0) < 0:
    raise newTinamouException(SE_PLAY_ERROR_CODE, "Could not play SE " & self.src & ". " & $sdl2.getError())

proc stopAllEffects*() =
  ## Stop sound.
  discard haltChannel(-1)

proc newSoundManager*(numchans: int): TSoundManager =
  ## Create new sound manager.
  new result
  result.bgms = newTable[string, TMusic]()
  result.ses = newTable[string, TSoundEffect]()

  discard allocateChannels(numchans.cint)

proc setMusic*(self: TSoundManager; name, path: static[string]): TSoundManager {.discardable.} =
  ## Set new background music.
  if not self.bgms.hasKey(name):
    self.bgms.add(name, newMusic(path))

proc setMusic*(self: TSoundManager; name: static[string]; src: RWopsPtr): TSoundManager {.discardable.} =
  ## Set new background music from embedded data.
  if not self.bgms.hasKey(name):
    self.bgms.add(name, newMusicFromRW(src))

proc setEffect*(self: TSoundManager; name, path: static[string]): TSoundManager {.discardable.} =
  ## Set new sound effect.
  if not self.ses.hasKey(name):
    self.ses.add(name, newSoundEffect(path))

proc setEffect*(self: TSoundManager; name: static[string], src: RWopsPtr): TSoundManager {.discardable.} =
  ## Set new sound effect from embedded data.
  if not self.ses.hasKey(name):
    self.ses.add(name, newSoundEffectFromRW(src))

proc getMusic*(self: TSoundManager, name: string): TMusic =
  ## Get music.
  if self.bgms.hasKey(name):
    return self.bgms[name]
  else:
    raise newTinamouException(BGM_NOT_FOUND_ERROR_CODE, "Music '" & name & "' was not registered.")

proc getEffect*(self: TSoundManager, name: string): TSoundEffect =
  ## Get sound effect.
  if self.ses.hasKey(name):
    return self.ses[name]
  else:
    raise newTinamouException(SE_NOT_FOUND_ERROR_CODE, "Sound '" & name & "' was not registered.")

proc setMusicVolume*(vol: float) =
  ## Set musics' volume.
  ## `vol` must be in 0–1.
  discard mixer.volumeMusic((vol * MIX_MAX_VOLUME).toInt.cint)

proc getMusicVolume*(): float =
  ## Get musics' volume.
  return mixer.volumeMusic(-1.cint) / MIX_MAX_VOLUME

proc setEffectVolume*(vol: float) =
  ## Set sound effects' volume.
  ## `vol` must be in 0–1.
  discard mixer.volume(-1.cint, (vol * MIX_MAX_VOLUME).toInt.cint)

proc getEffectVolume*(): float =
  ## Get sound effects' volume.
  return mixer.volume(-1.cint, -1.cint) / MIX_MAX_VOLUME

proc destroy*(self: TSoundManager) =
  ## Free sound manager resources.
  for bgm in self.bgms.values:
    freeMusic bgm.music
  clear self.bgms

  for se in self.ses.values:
    freeChunk se.chunk
  clear self.ses
