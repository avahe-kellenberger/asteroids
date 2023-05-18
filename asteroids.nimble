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

task release, "Builds the game":
  exec "nim r -d:release src/asteroids.nim -o:./bin/asteroids"

