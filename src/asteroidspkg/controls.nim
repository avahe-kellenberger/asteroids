import shade

type Control* = ref object
  name*: string
  key*: KeyCode

var
  thrustControl*: Control = Control(name: "Thrust", key: K_W)
  slowDownControl*: Control = Control(name: "Slow Down", key: K_S)

