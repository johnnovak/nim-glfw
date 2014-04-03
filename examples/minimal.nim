import
  pure/os,
  glfw/glfw

glfw.init()

var
  win = newWin()

sleep(1000)
win.destroy()
glfw.terminate()
