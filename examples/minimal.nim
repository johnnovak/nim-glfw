import
  pure/os,
  glfw/glfw

var
  wnd = newWnd()

sleep(1000)
wnd.destroy()
glfw.terminate()
