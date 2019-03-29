## Sound Manager

import
  tables,

  sdl2,
  sdl2.mixer,

  exception

type
  Music* = ref object of RootObj
    src: string
    music: MusicPtr

  SoundEffect* = ref object of RootObj
    src: string
    chunk: ChunkPtr

  SoundManager* = ref object of RootObj
    bgms: TableRef[string, Music]
    ses: TableRef[string, SoundEffect]

proc newMusic(path: static[string]): Music =
  ## Create new music.
  new result
  result.src = path
  result.music = loadMUS(path)

proc newMusicFromRW(src: RWopsPtr): Music =
  ## Create new music from data.
  new result
  result.src = "#!EMBEDDED"
  result.music = loadMUS_RW(src, 1)

proc play*(self: Music) =
  ## Play music.
  if playMusic(self.music, -1) < 0:
    raise newTinamouException(BGM_PLAY_ERROR_CODE, "Could not play music " & self.src & ". " & $sdl2.getError())

proc stopMusic*() =
  ## Stop background music.
  discard haltMusic()

proc newSoundEffect(path: static[string]): SoundEffect =
  ## Create new sound effect.
  new result
  result.src = path
  result.chunk = loadWAV(path)

  if result.chunk.isNil:
    raise newTinamouException(SE_LOAD_ERROR_CODE, "Could not play SE " & path & ". " & $sdl2.getError())

proc newSoundEffectFromRW(src: RWopsPtr): SoundEffect =
  ## Create new sound effect from data.
  new result
  result.src = "#!EMBEDDED"
  result.chunk = loadWAV_RW(src, 1)

proc play*(self: SoundEffect) =
  ## Play sound.
  if playChannel(-1, self.chunk, 0) < 0:
    when appType == "console":
      stderr.writeLine "tinamou: Could not play SE ", self.src, ". ", sdl2.getError()

proc stopAllEffects*() =
  ## Stop sound.
  discard haltChannel(-1)

proc newSoundManager*(numchans: int): SoundManager =
  ## Create new sound manager.
  new result
  result.bgms = newTable[string, Music]()
  result.ses = newTable[string, SoundEffect]()

  discard allocateChannels(numchans.cint)

proc setMusic*(self: SoundManager; name, path: static[string]): SoundManager {.discardable.} =
  ## Set new background music.
  if not self.bgms.hasKey(name):
    self.bgms.add(name, newMusic(path))

proc setMusic*(self: SoundManager; name: static[string]; src: RWopsPtr): SoundManager {.discardable.} =
  ## Set new background music from embedded data.
  if not self.bgms.hasKey(name):
    self.bgms.add(name, newMusicFromRW(src))

proc setEffect*(self: SoundManager; name, path: static[string]): SoundManager {.discardable.} =
  ## Set new sound effect.
  if not self.ses.hasKey(name):
    self.ses.add(name, newSoundEffect(path))

proc setEffect*(self: SoundManager; name: static[string], src: RWopsPtr): SoundManager {.discardable.} =
  ## Set new sound effect from embedded data.
  if not self.ses.hasKey(name):
    self.ses.add(name, newSoundEffectFromRW(src))

proc getMusic*(self: SoundManager, name: string): Music =
  ## Get music.
  if self.bgms.hasKey(name):
    return self.bgms[name]
  else:
    raise newTinamouException(BGM_NOT_FOUND_ERROR_CODE, "Music '" & name & "' was not registered.")

proc getEffect*(self: SoundManager, name: string): SoundEffect =
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

proc destroy*(self: SoundManager) =
  ## Free sound manager resources.
  for bgm in self.bgms.values:
    freeMusic bgm.music
  clear self.bgms

  for se in self.ses.values:
    freeChunk se.chunk
  clear self.ses
