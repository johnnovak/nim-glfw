import os, glfw

proc main =
  glfw.initialize()

  var c = DefaultOpenglWindowConfig
  c.title = "Minimal Nim-GLFW example"

  var w = newWindow(c)

  sleep(1000)

  w.destroy()
  glfw.terminate()

main()
