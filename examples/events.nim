from strutils import formatFloat, ffDecimal
from unicode import toUTF8, Rune
import glfw/glfw

proc winPosCb(o: Win, pos: tuple[x, y: int]) =
  echo "Window position: ", pos

proc mouseBtnCb(
    o: Win, btn: MouseBtn, pressed: bool, modKeys: ModifierKeySet) =
  echo($btn, ": ", if pressed: "down" else: "up")

proc winSizeCb(o: Win not nil, res: tuple[w, h: int]) =
  echo "Window size: ", res

proc winFramebufSizeCb(o: Win, res: tuple[w, h: int]) =
  echo "Window framebuffer size: ", res

proc winCloseCb(o: Win) =
  echo "Window close event"

var nWinRefreshes = 0

proc winRefreshCb(o: Win) =
  nWinRefreshes += 1

proc cursorPosCb(o: Win, pos: tuple[x, y: float64]) =
  let xy = (x: formatFloat(pos.x, ffDecimal, 2),
            y: formatFloat(pos.y, ffDecimal, 2))
  echo "Cursor pos: ", xy

proc cursorEnterCb(o: Win, entered: bool) =
  echo "The cursor ", if entered: "entered" else: "left", " the window area"

proc winFocusCb(o: Win; focused: bool) =
  echo if focused: "Gained" else: "Lost", " window focus"

proc winIconifyCb(o: Win; iconified: bool) =
  echo "Window ", if iconified: "iconified" else: "un-iconified"

proc scrollCb(o: Win, offset: tuple[x, y: float64]) =
  let xy = (x: formatFloat(offset.x, ffDecimal, 2),
            y: formatFloat(offset.y, ffDecimal, 2))
  echo "Mouse scroll: ", xy

proc charCb(o: Win, codePoint: Rune) =
  echo "Unicode char: ", codePoint.toUTF8()

proc keyCb(o: Win, key: Key, scanCode: int, action: KeyAction,
    modKeys: ModifierKeySet) =
  echo("Key: ", key, " (scan code: ", scanCode, "): ", action)

  if action != kaUp:
    if key == keyEscape or key == keyF4 and mkAlt in modKeys:
      o.shouldClose = true

glfw.init()

var done = false

# All arguments are optional. For OpenGL ES, use newGlEsWin.
var win = newGlWin(
  dim = (w: 640, h: 480),
  title = "Event example",
  fullscreen = nilMonitor(), # No monitor specified; don't go fullscreen.
  shareResourcesWith = nilWin(), # Don't share resources.
  visible = true,
  decorated = true,
  resizable = false,
  stereo = false,
  srgbCapableFramebuf = false,
  bits = (r: 8, g: 8, b: 8, a: 8, stencil: 8, depth: 24),
  accumBufBits = (r: 0, g: 0, b: 0, a: 0),
  nAuxBufs = 0,
  nMultiSamples = 0,
  refreshRate = 0, # Use the current refresh rate.
  version = glv30,
  forwardCompat = false,
  debugContext = false,
  profile = glpAny,
  robustness = glrNone
)

setControlCHook(proc() {.noconv.} = done = true)

# Set up event handlers.
win.winPosCb = winPosCb
win.mouseBtnCb = mouseBtnCb
win.winSizeCb = winSizeCb
win.keyCb = keyCb
win.framebufSizeCb = winFramebufSizeCb
win.winCloseCb = winCloseCb
win.winRefreshCb = winRefreshCb
win.cursorPosCb = cursorPosCb
win.cursorEnterCb = cursorEnterCb
win.winFocusCb = winFocusCb
win.winIconifyCb = winIconifyCb
win.scrollCb = scrollCb
win.charCb = charCb
win.keyCb = keyCb

while not done and not win.shouldClose:
  win.update() # Buffer swap + event poll.

win.destroy()
glfw.terminate()
