## Manager for Multiple Scenes

import
  tables,

  scene,
  exception

type
  TSceneManager* = ref object of RootObj
    table: TableRef[TSceneId, TBaseScene]

proc newSceneManager*: TSceneManager =
  new result
  result.table = newTable[string, TBaseScene]()

proc setScene*(self: TSceneManager, name: string, scene: TBaseScene) =
  if not self.table.hasKey(name):
    self.table.add(name, scene)

proc getScene*(self: TSceneManager, name: string): TBaseScene =
  try:
    result = self.table[name]
  except KeyError:
    raise newTinamouException(SCENE_NOT_FOUND_ERROR_CODE, "There is no scene named '" & name & "'.")
