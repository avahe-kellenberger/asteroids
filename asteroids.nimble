import std/[os, strformat]

# Package
version = "0.1.0"
author = "Avahe Kellenberger"
description = "Asteroids clone"
license = "?"
srcDir = "src"
bin = @["asteroids"]

# Dependencies
requires "nim >= 1.6.12"
requires "https://github.com/avahe-kellenberger/shade"

task runr, "Runs the game":
  exec "nim r -d:release src/asteroids.nim"

task debug, "Runs the game in debug mode":
  exec "nim r -d:debug src/asteroids.nim"

task release, "Builds the game":
  exec "nim c -d:release src/asteroids.nim -o:./bin/asteroids"

proc deploy(sharedLibExt: string, extraBuildFlags: string = "") =
  exec fmt"nim c {extraBuildFlags} --app:gui -d:release --outdir:dist/asteroids src/asteroids.nim"
  cpDir("assets", "dist/asteroids/assets")
  for sharedLibFile in listFiles(".usr/lib"):
    if sharedLibFile.endsWith(sharedLibExt):
      let filename = extractFilename(sharedLibFile)
      cpFile(sharedLibFile, "dist/asteroids/" & filename)

task deploy_linux, "Deploys a production release of the game for Windows":
  deploy(".so")

task deploy_windows, "Deploys a production release of the game for Windows":
  deploy(".dll", "-d:mingw")

task deploy, "Deploys a production release of the game":
  when defined(linux):
    deploy_linuxTask()
  else:
    deploy_windowsTask()

