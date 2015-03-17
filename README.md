# nim-glfw
A GLFW 3 wrapper for Nim.

## examples

This example displays a window for one second and then terminates:
```nim
import os, glfw/glfw
  
glfw.init()
var win = newWin()
sleep(1000)
win.destroy()
glfw.terminate()
```
To run the examples, simply invoke the compiler as such from the examples directory:
~~~
nim c -r <module>
~~~

## documentation
Currently no documentation exists, but a convenient symbol list can be generated simply by invoking this from the root directory:
~~~
nim doc2 lib/glfw/glfw.nim
~~~

## Version history
* 0.2
  * renamed symbols
      TGL_API -> GlApi

      PWin -> Win
      
      geNoErr -> glerrNoError
      
      TGLFW_Err -> GlfwError
      
      TGL_ES_version -> GlEsVersion
      
      and so on
      
  * newWin has been replaced with newGlWin and newGlEsWin
  
