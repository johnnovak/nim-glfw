from std/strutils import formatFloat, ffDecimal, `%`
from std/unicode import toUtf8

import glfw

{.experimental: "notnil".}

var done = false

proc formatFloat(f: float): string =
  formatFloat(f, ffDecimal, 2)

proc windowPositionCb(w: Window, pos: tuple[x, y: int32]) =
  echo "Window position: ($1, $2)" % [$pos.x, $pos.y]

{.push warning[HoleEnumConv]:off.}

proc mouseButtonCb(
    w: Window, b: MouseButton, pressed: bool, mods: set[ModifierKey]) =
  let pressedStr = if pressed: "down" else: "up"
  echo "$1: $2 - modifiers: $3" % [$b, pressedStr, $mods]

{.pop.}

proc windowSizeCb(w: Window not nil, size: tuple[w, h: int32]) =
  echo "Window size: $1x$2" % [$size.w, $size.h]

proc windowFramebufferSizeCb(w: Window, size: tuple[w, h: int32]) =
  echo "Window framebuffer size: $1x$2" % [$size.w, $size.h]

proc windowCloseCb(w: Window) =
  echo "Window close event"
  done = true

proc windowRefreshCb(w: Window) =
  echo "Window refresh event"

proc cursorPositionCb(w: Window, pos: tuple[x, y: float64]) =
  echo "Cursor position: ($1, $2)" % [formatFloat(pos.x), formatFloat(pos.y)]

proc cursorEnterCb(w: Window, entered: bool) =
  let enteredStr = if entered: "entered" else: "left"
  echo "The cursor has ", enteredStr, " the window area"

proc windowFocusCb(w: Window; focused: bool) =
  echo if focused: "Gained" else: "Lost", " window focus"

proc windowIconifyCb(w: Window; iconified: bool) =
  let iconifiedStr = if iconified: "iconified" else: "un-iconified"
  echo "Window ", iconifiedStr

proc scrollCb(w: Window, offset: tuple[x, y: float64]) =
  let xy = (x: formatFloat(offset.x),
            y: formatFloat(offset.y))
  echo "Mouse scroll: ", xy

proc charCb(w: Window, codePoint: Rune) =
  echo "Character: ", codePoint.toUTF8()

proc keyCb(w: Window, key: Key, scanCode: int32, action: KeyAction,
    mods: set[ModifierKey]) =
  echo "Key: $1 (scan code: $2): $3 - $4" % [$key, $scanCode, $action, $mods]

  if action != kaUp and (key == keyEscape or key == keyF4 and mkAlt in mods):
    done = true

proc dropCb(w: Window, paths: PathDropInfo) =
  echo "Path drop event:"
  for x in paths:
    echo "    ", x

proc registerWindowCallbacks(w: Window) =
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
  w.dropCb = dropCb

proc registerGlobalCallbacks =
  glfw.setMonitorCb(proc(m: Monitor, connected: bool) =
    let connectedStr = if connected: "connected" else: "disconnected"
    echo "A monitor (", m.name, ") has been", connectedStr 
  )
  glfw.setJoystickCb(proc(joy: int32, connected: bool) =
    let connectedStr = if connected: "connected" else: "disconnected"
    echo "Joystick #", joy, "has been", connectedStr
  )

proc main =
  glfw.initialize()

  # long and short version (only the window titles differ)
  when false:
    var w = newWindow()
  else:
    var c = DefaultOpenglWindowConfig
    c.title = "Nim-GLFW events example"
    c.size = (w: 640, h: 480)
    c.fullscreenMonitor = NoMonitor
    c.shareResourcesWith = nil.Window
    c.bits = (r: some(8i32), g: some(8i32), b: some(8i32), a: some(8i32), stencil: some(8i32), depth: some(24i32))
    c.accumBufferBits = (r: some(0i32), g: some(0i32), b: some(0i32), a: some(0i32))
    c.resizable = true
    c.visible = true
    c.decorated = true
    c.autoIconify = true
    c.focused = true
    c.floating = false
    c.maximized = false
    c.stereo = false
    c.srgbCapableFramebuffer = false
    c.nAuxBuffers = 0
    c.doubleBuffer = true
    c.nMultiSamples = 0
    c.refreshRate = some(0i32)
    c.version = glv10
    c.forwardCompat = false
    c.profile = opAnyProfile
    c.debugContext = false
    c.contextRobustness = crNoRobustness
    c.contextCreationApi = ccaNativeContextApi
    c.contextReleaseBehavior = crbAnyReleaseBehavior
    c.contextNoError = false
    c.makeContextCurrent = true
    var w = newWindow(c)

  defer:
    w.destroy()
    glfw.terminate()

  setControlCHook(proc() {.noconv.} = done = true)

  w.registerWindowCallbacks()
  registerGlobalCallbacks()

  while not done:
    w.swapBuffers()
    glfw.pollEvents()

main()
