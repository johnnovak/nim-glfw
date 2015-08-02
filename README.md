# nim-glfw
A GLFW 3 wrapper for Nim.

## examples

This example displays a window for one second and then terminates:
```nim
import os, glfw

glfw.init()
var win = newGlWin()
sleep(1000)
win.destroy()
glfw.terminate()
```
To run the examples, simply invoke the compiler as such from the root directory:
~~~
nim c -p:lib -r examples/<source file>
~~~

## documentation
Currently no documentation exists, but a convenient symbol list can be generated simply by invoking this from the root directory:
~~~
nim doc2 lib/glfw.nim
~~~

## Version history
* 0.2.1
  * fix import errors
  * fix linker errors on windows
  * update nimble metadata
  * update the README example

* 0.2
  * renamed symbols
      TGL_API -> GlApi

      PWin -> Win
      
      geNoErr -> glerrNoError
      
      TGLFW_Err -> GlfwError
      
      TGL_ES_version -> GlEsVersion
      
      and so on
      
  * newWin has been replaced with newGlWin and newGlEsWin
  
