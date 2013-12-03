from pure/strutils import
  formatFloat,
  TFloatformat

from pure/unicode import
  toUTF8

import glfw/glfw

proc wndPosCb(o: PWnd, pos: tuple[x, y: int]) =
  echo "Window position: ", pos

proc mouseBtnCb(
    o: PWnd, btn: TMouseBtn, pressed: bool, modKeys: TModifierKeySet) =
  echo($btn, ": ", if pressed: "down" else: "up")

proc wndSizeCb(o: PWnd not nil, res: tuple[w, h: int]) =
  echo "Window size: ", res

proc wndFramebufSizeCb(o: PWnd, res: tuple[w, h: int]) =
  echo "Window framebuffer size: ", res

proc wndCloseCb(o: PWnd) =
  echo "Window close event"

var nWinRefreshes = 0

proc wndRefreshCb(o: PWnd) =
  nWinRefreshes += 1

proc cursorPosCb(o: PWnd, pos: tuple[x, y: float64]) =
  let xy = (x: formatFloat(pos.x, ffDecimal, 2),
            y: formatFloat(pos.y, ffDecimal, 2))
  echo "Cursor pos: ", xy

proc cursorEnterCb(o: PWnd, entered: bool) =
  echo "The cursor ", if entered: "entered" else: "left", " the window area"

proc wndFocusCb(o: PWnd; focused: bool) =
  echo if focused: "Gained" else: "Lost", " window focus"

proc wndIconifyCb(o: PWnd; iconified: bool) =
  echo "Window ", if iconified: "iconified" else: "un-iconified"

proc scrollCb(o: PWnd, offset: tuple[x, y: float64]) =
  let xy = (x: formatFloat(offset.x, ffDecimal, 2),
            y: formatFloat(offset.y, ffDecimal, 2))
  echo "Mouse scroll: ", xy

proc charCb(o: PWnd, codePoint: TRune) =
  echo "Unicode char: ", codePoint.toUTF8()

proc keyCb(o: PWnd, key: TKey, scanCode: int, action: TKeyAction,
    modKeys: TModifierKeySet) =
  echo("Key: ", key, " (scan code: ", scanCode, "): ", action)

  if action != kaUp:
    if key == keyEscape or key == keyF4 and mkAlt in modKeys:
      o.shouldClose = true

var
  done = false
  wnd = newWnd()

setControlCHook(proc() {.noconv.} = done = true)

# Set up event handlers.
wnd.wndPosCb = wndPosCb
wnd.mouseBtnCb = mouseBtnCb
wnd.wndSizeCb = wndSizeCb
wnd.keyCb = keyCb
wnd.framebufSizeCb = wndFramebufSizeCb
wnd.wndCloseCb = wndCloseCb
wnd.wndRefreshCb = wndRefreshCb
wnd.cursorPosCb = cursorPosCb
wnd.cursorEnterCb = cursorEnterCb
wnd.wndFocusCb = wndFocusCb
wnd.wndIconifyCb = wndIconifyCb
wnd.scrollCb = scrollCb
wnd.charCb = charCb
wnd.keyCb = keyCb

while not done and not wnd.shouldClose:
  wnd.update() # Buffer swap + event poll.

wnd.destroy()
glfw.terminate()
