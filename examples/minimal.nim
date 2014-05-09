import os, glfw/glfw

glfw.init()
var win = newWin(title = "Minimal example")
sleep(1000)
win.destroy()
glfw.terminate()
