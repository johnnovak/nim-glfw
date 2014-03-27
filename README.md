# nim-glfw
A high-level GLFW 3 wrapper for Nimrod.

## examples

This example displays a window for one second and then terminates:
```nimrod
import
  os,
  glfw/glfw
  
glfw.init()
var
  win = newWin()
sleep(1000)
win.destroy()
glfw.terminate()
```
To run the examples, simply invoke the compiler as such from the examples directory:
~~~
nimrod c -r <module>
~~~

## documentation
Currently no documentation exists, but a convenient symbol list can be generated simply by invoking this from the root directory:
~~~
nimrod doc2 lib/glfw/glfw.nim
~~~
