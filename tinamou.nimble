# Package

version       = "0.3.1"
author        = "Double_oxygeN"
description   = "Game Library in Nim with SDL2"
license       = "MIT"

srcDir        = "src"
skipDirs      = @["tests"]

# Dependencies

requires "nim >= 0.17.2"
requires "sdl2 >= 1.1"

# tasks

task release, "do release build":
  exec "nimble build -d:release --opt:speed --app:gui && strip ./bin/tinamou"

task cleanup, "clean up files":
  exec "rm -f bin/* && rm -rf src/nimcache"
  exec "find tests -type f ! -name \"*.*\" -delete && rm -rf tests/nimcache"

task docgen, "generate documentation":
  exec "nimble doc src/tinamou.nim --project -o:docs"

task test, "test codes":
  withDir "tests":
    exec "nim c -r test"
    exec "rm -f test"
