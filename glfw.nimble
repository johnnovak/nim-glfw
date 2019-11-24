#[ Package ]#

version     = "3.3.0.2"
author      = "Erik Johansson Andersson"
description = "GLFW 3 wrapper for Nim"
license     = "MIT"

skipDirs = @["examples"]

requires "nim >= 1.0.2"

task examples, "Compiles the examples with dynamic linking":
  exec "nim c examples/boing"
  exec "nim c examples/events"
  exec "nim c examples/gears"
  exec "nim c examples/minimal"
  exec "nim c examples/splitview"
  exec "nim c examples/triangle"
  exec "nim c examples/wave"

task examplesStatic, "Compiles the examples with static linking":
  exec "nim c -d:glfwStaticLib examples/boing"
  exec "nim c -d:glfwStaticLib examples/events"
  exec "nim c -d:glfwStaticLib examples/gears"
  exec "nim c -d:glfwStaticLib examples/minimal"
  exec "nim c -d:glfwStaticLib examples/splitview"
  exec "nim c -d:glfwStaticLib examples/triangle"
  exec "nim c -d:glfwStaticLib examples/wave"
