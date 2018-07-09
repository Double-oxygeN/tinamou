## Information shared between two scenes.

type
  SharedInfo* = ref object of RootObj
    ## Shared informations.
    ## Extend it and set what you want to share as fields.

let
  NOSHARE*: SharedInfo = new SharedInfo ## Use it when no information is shared.
