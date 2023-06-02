import shade
import std/[os, strformat, strutils]
import parsetoml

const
  configDir* = getConfigDir() & DirSep & "asteroids"
  configFile* = configDir & DirSep & "config"

template normalizeTomlKey(key: string): string =
  key.replace(" ", "-").toLower()

type Control* = ref object
  name*: string
  key*: KeyCode

var
  thrustControl*: Control = Control(name: "Thrust", key: K_W)
  slowDownControl*: Control = Control(name: "Slow Down", key: K_S)

proc controlsToString(): string =
  result = fmt"""
  [controls]
  {normalizeTomlKey(thrustControl.name)} = {ord(thrustControl.key)}
  {normalizeTomlKey(slowDownControl.name)} = {ord(slowDownControl.key)}
  """

proc saveControlsToFile*() =
  ## Saves the current controls to `configFile`.
  if not dirExists(configDir):
    createDir(configDir)

  writeFile(configFile, controlsToString())

proc loadControlsFromFile*() =
  if not fileExists(configFile):
    return

  let loadedConfig = parsetoml.parseFile(configFile)
  if loadedConfig.kind != TomlValueKind.Table:
    echo "Invalid config file! Controls unchanged."
    return

  # TODO: Error handling
  let config = loadedConfig.tableVal[]["controls"]
  thrustControl.key = KeyCode(config[normalizeTomlKey(thrustControl.name)].intVal)
  slowDownControl.key = KeyCode(config[normalizeTomlKey(slowDownControl.name)].intVal)

when isMainModule:
  saveControlsToFile()

