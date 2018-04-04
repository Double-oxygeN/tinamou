## Tinamou Game Library

import
  tinamoupkg.core,
  tinamoupkg.scene,
  tinamoupkg.imagemanager,
  tinamoupkg.soundmanager,
  tinamoupkg.painter,
  tinamoupkg.keyboard,
  tinamoupkg.mouse,
  tinamoupkg.tween

export
  core,
  scene,
  imagemanager,
  soundmanager,
  painter,
  keyboard,
  mouse,
  tween

when isMainModule:
  echo "This file was compiled on ", CompileDate, " at ", CompileTime
