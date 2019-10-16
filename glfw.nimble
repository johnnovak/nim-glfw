#[ Package ]#

version     = "0.3.1"
author      = "Erik Johansson Andersson"
description = "A GLFW 3 wrapper"
license     = "BSD"

skipDirs = @["examples"]

requires "nim >= 1.0.0"

task examplesStatic, "Compiles the examples with static linking":
  exec "nim c examples/boing"
  exec "nim c examples/events"
  exec "nim c examples/gears"
  exec "nim c examples/minimal"
  exec "nim c examples/simple"
  exec "nim c examples/splitview"
  exec "nim c examples/wave"
  exec "nim c -d:glfwStaticLib examples/boing"
  exec "nim c -d:glfwStaticLib examples/events"
  exec "nim c -d:glfwStaticLib examples/gears"
  exec "nim c -d:glfwStaticLib examples/minimal"
  exec "nim c -d:glfwStaticLib examples/simple"
  exec "nim c -d:glfwStaticLib examples/splitview"
  exec "nim c -d:glfwStaticLib examples/wave"
