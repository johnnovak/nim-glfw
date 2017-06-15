import os, glfw

glfw.initialize()
var config = initDefaultOpenglWindowConfig()
config.title = "Minimal example"
var window = newWindow(config)
sleep(1000)
window.destroy()
glfw.terminate()
