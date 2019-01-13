# Package

version       = "0.5.2"
author        = "Double_oxygeN"
description   = "Game Library in Nim with SDL2"
license       = "MIT"

srcDir        = "src"
skipDirs      = @["tests"]

# Dependencies

requires "nim >= 0.19.2"
requires "sdl2 >= 2.0"

# tasks

task docgen, "generate documentation":
  exec "nimble doc2 src/tinamou.nim --project -o:docs"

#task test, "test codes":
#  withDir "tests":
#    exec "nim c -r test"
#    exec "rm -f test"

