## Syntax sugar support.
##
## Usage
## ======
##
## ::
##   createScene(SampleScene):
##     # write member variables as vars
##     var
##       foo: int
##       bar: string
##
##     # method definition
##     init:
##       self.foo = 42
##       self.bar = "HELLO"
##
##       tools.imageManager.setImage "image-name", "./path/to/imagefile"
##
##     # name of type whose parent is SharedInfo puts in a bracket
##     init[SomeSharedInfo]:
##       self.foo = info.foo
##       self.bar = info.bar
##
##     update:
##       result = stay()
##       actions.keyboard.isPressed(KeyName.SPACE):
##         result = next("next-scene")
##
##     draw:
##       painter.clear 0, 0, 0
##
import macros, strformat

macro createScene*(sceneType: untyped, bodyStmt: untyped): typed =
  result = newStmtList()

  sceneType.expectKind nnkIdent
  bodyStmt.expectKind nnkStmtList

  let
    members = newNimNode nnkRecList
    methods = newStmtList()

  for bodyContent in bodyStmt:
    if bodyContent.kind == nnkVarSection:
      bodyContent.copyChildrenTo(members)

    elif bodyContent.kind == nnkCall:
      let
        hasBracket = (bodyContent[0].kind == nnkBracketExpr)
        sectionNameIdent = if hasBracket: bodyContent[0][0] else: bodyContent[0]
      sectionNameIdent.expectKind nnkIdent
      if hasBracket: bodyContent[0].expectLen 2

      if $sectionNameIdent notin ["init", "update", "draw"]:
        error(fmt"""Method name must be either "init", "update" or "draw", but got "{sectionNameIdent}".""", bodyContent[0])

      if $sectionNameIdent != "init" and hasBracket:
        warning("""Bracket notation is only valid for "init" method. This would be ignored.""", bodyContent[0][1])

      methods.add(nnkMethodDef.newTree(
        sectionNameIdent,
        newEmptyNode(),
        newEmptyNode(),
        (case $sectionNameIdent
        of "init":
          nnkFormalParams.newTree(
            newEmptyNode(),
            newIdentDefs(ident"self", sceneType),
            newIdentDefs(ident"tools", ident"Tools"),
            newIdentDefs(ident"info", if hasBracket: bodyContent[0][1] else: ident"SharedInfo"))
        of "update":
          nnkFormalParams.newTree(
            ident"Transition",
            newIdentDefs(ident"self", sceneType),
            newIdentDefs(ident"tools", ident"Tools"),
            newIdentDefs(ident"actions", ident"Actions"))
        of "draw":
          nnkFormalParams.newTree(
            newEmptyNode(),
            newIdentDefs(ident"self", sceneType),
            newIdentDefs(ident"painter", ident"Painter"),
            newIdentDefs(ident"tools", ident"Tools"),
            newIdentDefs(ident"actions", ident"Actions"))
        else:
          nnkFormalParams.newTree(
            ident"auto",
            newIdentDefs(ident"self", sceneType))),
        newEmptyNode(),
        newEmptyNode(),
        bodyContent[1]))

    else:
      error("Invalid syntax.", bodyContent)

  result.add nnkTypeSection.newTree(
    nnkTypeDef.newTree(
      nnkPostfix.newTree(ident"*", sceneType),
      newEmptyNode(),
      nnkRefTy.newTree(
        nnkObjectTy.newTree(
          newEmptyNode(),
          nnkOfInherit.newTree ident"BaseScene",
          members))))

  methods.copyChildrenTo(result)
