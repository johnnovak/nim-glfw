from strutils import formatFloat, ffDecimal
from unicode import toUtf8
import glfw

var done = false

proc windowPositionCb(o: Window, position: tuple[x, y: int32]) =
  echo "Window position: ", position

proc mouseButtonCb(
    o: Window, btn: MouseButton, pressed: bool, modKeys: set[ModifierKey]) =
  echo btn, ": ", if pressed: "down" else: "up", " - modifiers: ", modKeys

proc windowSizeCb(o: Window not nil, size: tuple[w, h: int32]) =
  echo "Window size: ", size

proc windowFramebufferSizeCb(o: Window, size: tuple[w, h: int32]) =
  echo "Window framebuffer size: ", size

proc windowCloseCb(o: Window) =
  echo "Window close event"
  done = true

var nWindowRefreshes = 0

proc windowRefreshCb(o: Window) =
  nWindowRefreshes += 1

proc cursorPositionCb(o: Window, pos: tuple[x, y: float64]) =
  let xy = (x: formatFloat(pos.x, ffDecimal, 2),
            y: formatFloat(pos.y, ffDecimal, 2))
  echo "Cursor pos: ", xy

proc cursorEnterCb(o: Window, entered: bool) =
  echo "The cursor ", if entered: "entered" else: "left", " the window area"

proc windowFocusCb(o: Window; focused: bool) =
  echo if focused: "Gained" else: "Lost", " window focus"

proc windowIconifyCb(o: Window; iconified: bool) =
  echo "Window ", if iconified: "iconified" else: "un-iconified"

proc scrollCb(o: Window, offset: tuple[x, y: float64]) =
  let xy = (x: formatFloat(offset.x, ffDecimal, 2),
            y: formatFloat(offset.y, ffDecimal, 2))
  echo "Mouse scroll: ", xy

proc charCb(o: Window, codePoint: Rune) =
  echo "Character: ", codePoint.toUTF8()

proc keyCb(o: Window, key: Key, scanCode: int32, action: KeyAction,
    modKeys: set[ModifierKey]) =
  echo("Key: ", key, " (scan code: ", scanCode, "): ", action, " - modifiers: ", modKeys)

  if action != kaUp and (key == keyEscape or key == keyF4 and mkAlt in modKeys):
    done = true

proc registerCallbacks(w: Window) =
  w.windowPositionCb = windowPositionCb
  w.mouseButtonCb = mouseButtonCb
  w.windowSizeCb = windowSizeCb
  w.keyCb = keyCb
  w.framebufferSizeCb = windowFramebufferSizeCb
  w.windowCloseCb = windowCloseCb
  w.windowRefreshCb = windowRefreshCb
  w.cursorPositionCb = cursorPositionCb
  w.cursorEnterCb = cursorEnterCb
  w.windowFocusCb = windowFocusCb
  w.windowIconifyCb = windowIconifyCb
  w.scrollCb = scrollCb
  w.charCb = charCb

proc main =
  glfw.initialize()

  when true:
    # This is almost identical to the branch following this one

    var c = initDefaultOpenglWindowConfig()
    c.resizable = true
    c.title = "nim-glfw events example"
    c.size = (w: 640, h: 480)
    c.bits = (r: 8, g: 8, b: 8, a: 8, stencil: 8, depth: 24)
    c.accumBufferBits = (r: 8, g: 8, b: 8, a: 8)
    c.fullscreen = nilMonitor()
    c.shareResourcesWith = nilWindow()
    c.visible = true
    c.decorated = true
    c.resizable = true
    c.stereo = false
    c.srgbCapableFramebuffer = false
    c.nAuxBuffers = 0
    c.nMultiSamples = 0
    c.refreshRate = 0
    c.openglApi = initOpenglApi(glv20, forwardCompat = false,
                                debugContext = false, profile = glpAny,
                                robustness = glrNone)

    var w = newWindow(c, makeContextCurrent = true)
  else:
    var w = newWindow(initDefaultOpenglConfig())
  #w.pos = (x: 100, y: 100)

  defer:
    w.destroy()
    glfw.terminate()

  setControlCHook(proc() {.noconv.} = done = true)

  w.registerCallbacks()

  while not done:
    w.swapBuffers()
    glfw.pollEvents()

  echo "The window was refreshed ", nWindowRefreshes, " times"

main()