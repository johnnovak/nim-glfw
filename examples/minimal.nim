import
  pure/os,
  glfw/glfw

glfw.init()

var
  wnd = newWnd()

sleep(1000)
wnd.destroy()
glfw.terminate()
