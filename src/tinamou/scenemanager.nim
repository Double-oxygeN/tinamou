## Manager for Multiple Scenes

import
  tables,

  scene,
  exception

type
  SceneManager* = ref object of RootObj
    table: TableRef[SceneId, BaseScene]

proc newSceneManager*: SceneManager =
  ## Create new SceneManager.
  new result
  result.table = newTable[string, BaseScene]()

proc setScene*(self: SceneManager, name: string, scene: BaseScene) =
  ## Set scene with key string.
  if not self.table.hasKey(name):
    self.table.add(name, scene)

proc getScene*(self: SceneManager, name: string): BaseScene =
  ## Get scene by key string.
  ## If no scenes are found, then throw exception.
  try:
    result = self.table[name]
  except KeyError:
    raise newTinamouException(SCENE_NOT_FOUND_ERROR_CODE, "There is no scene named '" & name & "'.")
