from wrappers/opengl/opengl import
  loadExtensions

from pure/collections/tables import
  `[]`,
  `[]=`,
  add,
  initTable,
  hasKey

static:
  when cushort isnot uint16:
    {.fatal: "cushort != uint16: " &
             "not binary compatible with glfw; please report this.".}

  when cuint isnot uint32:
    {.fatal: "cuint != uint32: " &
             "not binary compatible with glfw; please report this.".}

from pure/strutils import
  toLower

from pure/unicode import
  TRune
export TRune

import wrapper
export wrapper.pollEvents
export wrapper.waitEvents

type
  TMouseBtn* = enum
    mbLeft = (0, "Left mouse button")
    mbRight = (1, "Right mouse button")
    mbMiddle = (2, "Middle mouse button")
    mb4 = (3, "Mouse button 4")
    mb5 = (4, "Mouse button 5")
    mb6 = (5, "Mouse button 6")
    mb7 = (6, "Mouse button 7")
    mb8 = (7, "Mouse button 8")
  TKey* = enum
    keyUnknown = -1
    keySpace = 32
    keyApostrophe = 39
    keyComma = 44
    keyMinus = 45
    keyPeriod = 46
    keySlash = 47
    key0 = 48
    key1 = 49
    key2 = 50
    key3 = 51
    key4 = 52
    key5 = 53
    key6 = 54
    key7 = 55
    key8 = 56
    key9 = 57
    keySemicolon = 59
    keyEqual = 61
    keyA = 65
    keyB = 66
    keyC = 67
    keyD = 68
    keyE = 69
    keyF = 70
    keyG = 71
    keyH = 72
    keyI = 73
    keyJ = 74
    keyK = 75
    keyl = 76
    keyM = 77
    keyN = 78
    keyO = 79
    keyP = 80
    keyQ = 81
    keyR = 82
    keyS = 83
    keyT = 84
    keyU = 85
    keyV = 86
    keyW = 87
    keyX = 88
    keyY = 89
    keyZ = 90
    keyLeftBracket = 91
    keyBackslash = 92
    keyRightBracket = 93
    keyGraveAccent = 96
    keyWorld1 = 161
    keyWorld2 = 162
    keyEscape = 256
    keyEnter = 257
    keyTab = 258
    keyBackspace = 259
    keyInsert = 260
    keyDelete = 261
    keyRight = 262
    keyLeft = 263
    keyDown = 264
    keyUp = 265
    keyPageUp = 266
    keyPageDown = 267
    keyHome = 268
    keyEnd = 269
    keyCapsLock = 280
    keyScrollLock = 281
    keyNumLock = 282
    keyPrintScreen = 283
    keyPause = 284
    keyF1 = 290
    keyF2 = 291
    keyF3 = 292
    keyF4 = 293
    keyF5 = 294
    keyF6 = 295
    keyF7 = 296
    keyF8 = 297
    keyF9 = 298
    keyF10 = 299
    keyF11 = 300
    keyF12 = 301
    keyF13 = 302
    keyF14 = 303
    keyF15 = 304
    keyF16 = 305
    keyF17 = 306
    keyF18 = 307
    keyF19 = 308
    keyF20 = 309
    keyF21 = 310
    keyF22 = 311
    keyF23 = 312
    keyF24 = 313
    keyF25 = 314
    keyKp0 = 320
    keyKp1 = 321
    keyKp2 = 322
    keyKp3 = 323
    keyKp4 = 324
    keyKp5 = 325
    keyKp6 = 326
    keyKp7 = 327
    keyKp8 = 328
    keyKp9 = 329
    keyKpDecimal = 330
    keyKpDivide = 331
    keyKpMultiply = 332
    keyKpSubtract = 333
    keyKpAdd = 334
    keyKpEnter = 335
    keyKpEqual = 336
    keyLeftShift = 340
    keyLeftControl = 341
    keyLeftAlt = 342
    keyLeftSuper = 343
    keyRightShift = 344
    keyRightControl = 345
    keyRightAlt = 346
    keyRightSuper = 347
    keyMenu = 348
  TKeyAction* = enum
    kaUp = (0, "up")
    kaDown = (1, "down")
    kaRepeat = (2, "repeat")
  TModifierKey* = enum
    mkShift = (wrapper.MOD_SHIFT, "shift")
    mkCtrl = (wrapper.MOD_CONTROL, "ctrl")
    mkAlt = (wrapper.MOD_ALT, "alt")
    mkSuper = (wrapper.MOD_SUPER, "super")
  TModifierKeySet* = set[TModifierKey]

{.push closure.}
type
  PWndHandle = wrapper.GLFWwindow
  TWnd* = object
    handle: PWndHandle

    wndPosCb*: TWndPosCb
    wndSizeCb*: TWndSizeCb
    wndCloseCb*: TWndCloseCb
    wndRefreshCb*: TWndRefreshCb
    wndFocusCb*: TWndFocusCb
    wndIconifyCb*: TWndIconifyCb
    framebufSizeCb*: TframebufSizeCb
    mouseBtnCb*: TMouseBtnCb
    cursorPosCb*: TCursorPosCb
    cursorEnterCb*: TCursorEnterCb
    scrollCb*: TScrollCb
    keyCb*: TKeyCb
    charCb*: TCharCb
  PWnd* = ref TWnd
  TWndPosCb* = proc(wnd: PWnd, pos: tuple[x, y: int])
  TWndSizeCb* = proc(wnd: PWnd, res: tuple[w, h: int])
  TWndCloseCb* = proc(wnd: PWnd)
  TWndRefreshCb* = proc(wnd: PWnd)
  TWndFocusCb* = proc(wnd: PWnd, focus: bool)
  TWndIconifyCb* = proc(wnd: PWnd, iconified: bool)
  TFramebufSizeCb* = proc(wnd: PWnd, res: tuple[w, h: int])
  TMouseBtnCb* = proc(wnd: PWnd, btn: TMouseBtn, pressed: bool,
    modKeys: TModifierKeySet)
  TCursorPosCb* = proc(wnd: PWnd, pos: tuple[x, y: float64])
  TCursorEnterCb* = proc(wnd: PWnd, entered: bool)
  TScrollCb* = proc(wnd: PWnd, offset: tuple[x, y: float64])
  TKeyCb* = proc(wnd: PWnd, key: TKey, scanCode: int, action: TKeyAction,
    modKeys: TModifierKeySet)
  TCharCb* = proc(wnd: PWnd, codePoint: TRune)
  PMonitorHandle = wrapper.GLFWmonitor
  TMonitor* = object
    handle: PMonitorHandle
{.pop.} # closure.

proc initModifierKeySet(bitfield: int): TModifierKeySet =
  for x in TModifierKey:
    if (bitfield and x.int) != 0:
      result.incl((bitfield and x.int).TModifierKey)

type
  TGLFW_Err* = enum
    geNoErr = (wrapper.NOT_INITIALIZED - 2, "no error")
    geUnknownErr = (wrapper.NOT_INITIALIZED - 1, "unknown error")
    geNotInit = (wrapper.NOT_INITIALIZED, "not initialized")
    geNoCurrContext = (wrapper.NO_CURRENT_CONTEXT, "no current context")
    geInvalidEnum = (wrapper.INVALID_ENUM, "invalid enum")
    geInvalidValue = (wrapper.INVALID_VALUE, "invalid value")
    geOutOfMemory = (wrapper.OUT_OF_MEMORY, "out of memory")
    geApiUnavail = (wrapper.API_UNAVAILABLE, "API unavailable")
    geVersionUnavail = (wrapper.VERSION_UNAVAILABLE, "version unavailable")
    gePlatformErr = (wrapper.PLATFORM_ERROR, "platform error")
    geFmtUnavail = (wrapper.FORMAT_UNAVAILABLE, "format unavailable")

var
  gErrCode = geNoErr
  gErrMsg = ""

type
  EGLFW* = object of E_Base
    err*: TGLFW_Err

proc fail(err = geUnknownErr, msg: string = "", iff = true) =
  if not iff:
    return

  var e = newException(EGLFW, if msg != "": msg else: $err)
  gErrCode = geNoErr
  gErrMsg.setLen(0)
  e.err = err
  raise e

proc errCheck =
  if gErrCode != geNoErr:
    fail(gErrCode, gErrMsg)

proc failIf(val, equals: expr, msg = ""): expr =
  let val = val
  errCheck()
  if val == equals:
    fail(msg = msg)
  val

# We can't raise an exception here, because that might mess up the GLFW stack.
proc errCb(code: cint, msg: cstring) {.cdecl.} =
  gErrCode = TGLFW_Err(code)
  gErrMsg = $msg

proc newMonitor*(handle: PMonitorHandle): TMonitor =
  result.handle = handle

type
  TMonitorCb* = proc(monitor: TMonitor, connected: bool) {.closure.}

var monitorCb: TMonitorCb

proc `monitorCb=`*(cb: TMonitorCb) =
  monitorCb = cb

proc internalMonitorCb(handle: PMonitorHandle, connected: cint) {.cdecl.} =
  if not monitorCb.isNil:
    monitorCb(TMonitor(handle: handle), connected.bool)

proc getMonitors*: seq[TMonitor] =
  var count: cint
  var handlesPtr = wrapper.getMonitors(count.addr).failIf(nil)
  fail(iff = count <= 0)
  var handles = cast[ptr array[count.int - 1, PMonitorHandle]](handlesPtr)

  result = @[]
  for i in 0 .. <count:
    result.add(newMonitor(handles[i]))

proc getPrimaryMonitor*: TMonitor =
  newMonitor(wrapper.getPrimaryMonitor().failIf(nil))

proc pos*(o: TMonitor): tuple[x, y: int] =
  var tmp = (0.cint, 0.cint)
  wrapper.getMonitorPos(o.handle, tmp[0].addr, tmp[1].addr)
  (tmp[0].int, tmp[1].int)

proc physicalSizeMM*(o: TMonitor): tuple[w, h: int] =
  var tmp = (0.cint, 0.cint)
  wrapper.getMonitorPhysicalSize(o.handle, tmp[0].addr, tmp[1].addr)
  (tmp[0].int, tmp[1].int)

proc name*(o: TMonitor): string =
  $wrapper.getMonitorName(o.handle).failIf(nil)

type
  TVidMode* = tuple[
    dim: tuple[w, h: int], bits: tuple[r, g, b: int], refreshRate: int]

proc vidModeConv(o: ptr wrapper.GLFWvidmode): TVidMode =
  ((o.width.int, o.height.int),
   (o.redBits.int, o.greenBits.int, o.blueBits.int), o.refreshRate.int)

proc vidModes*(o: TMonitor): seq[TVidMode] =
  var count: cint
  var modesPtr = wrapper.getVideoModes(o.handle, count.addr).failIf(nil)
  fail(iff = count <= 0)

  var modes = cast[ptr array[count.int - 1, GLFWvidmode]](modesPtr)
  result = @[]
  for i in 0 .. <count:
    result.add((
      dim: (w: modes[i].width.int, h: modes[i].height.int),
      bits: (
        r: modes[i].redBits.int,
        g: modes[i].greenBits.int,
        b: modes[i].blueBits.int),
      refreshRate: modes[i].refreshRate.int))

proc vidMode*(o: TMonitor): TVidMode =
  vidModeConv(wrapper.getVideoMode(o.handle).failIf(nil))

proc `gamma=`*(o: TMonitor, val: float32) =
  wrapper.setGamma(o.handle, val.cfloat)

type 
  TGammaRamp* = tuple[r, g, b: seq[uint16], size: int32]
  PGammaRamp* = ptr TGammaRamp

proc `gammaRamp=`*(o: TMonitor, ramp: TGammaRamp) =
  var x = ramp
  wrapper.setGammaRamp(o.handle, cast[ptr wrapper.GLFWgammaramp](x.addr))

proc gammaRamp*(o: TMonitor): PGammaRamp =
  cast[PGammaRamp](wrapper.getGammaRamp(o.handle).failIf(nil))

var
  hasInit = false

proc init* =
  if hasInit:
    return

  discard wrapper.setErrorCallback(errCb)
  discard wrapper.init().failIf(0)
  discard wrapper.setMonitorCallback(internalMonitorCb)
  hasInit = true

proc terminate* =
  wrapper.terminate()

proc nilMonitor*: TMonitor =
  nil

proc nilWnd*: PWnd =
  new(result)

var
  wndTable = initTable[PWndHandle, PWnd]()
wndTable[nil] = nil

proc handleToWnd(o: PWndHandle): PWnd =
  if wndTable.hasKey(o): wndTable[o] else: nilWnd()

var
  wndPosCb: GLFWwindowposfun
  wndSizeCb: GLFWwindowsizefun
  wndCloseCb: GLFWwindowclosefun
  wndRefreshCb: GLFWwindowrefreshfun
  wndFocusCb: GLFWwindowfocusfun
  wndIconifyCb: GLFWwindowiconifyfun
  framebufSizeCb: GLFWframebuffersizefun
  mouseBtnCb: GLFWmouseButtonfun
  cursorPosCb: GLFWcursorposfun
  cursorEnterCb: GLFWcursorenterfun
  scrollCb: GLFWscrollfun
  keyCb: GLFWkeyfun
  charCb: GLFWcharfun

type
  TGL_version* = enum
    glv10 = (0x10, "OpenGL 1.0")
    glv11 = (0x11, "OpenGL 1.1")
    glv12 = (0x12, "OpenGL 1.2")
    glv13 = (0x13, "OpenGL 1.3")
    glv14 = (0x14, "OpenGL 1.4")
    glv15 = (0x15, "OpenGL 1.5")
    glv20 = (0x20, "OpenGL 2.0")
    glv21 = (0x21, "OpenGL 2.1")
    glv30 = (0x30, "OpenGL 3.0")
    glv31 = (0x31, "OpenGL 3.1")
    glv32 = (0x32, "OpenGL 3.2")
    glv33 = (0x33, "OpenGL 3.3")
    glv40 = (0x40, "OpenGL 4.0")
    glv41 = (0x41, "OpenGL 4.1")
    glv42 = (0x42, "OpenGL 4.2")
    glv43 = (0x43, "OpenGL 4.3")
    glv44 = (0x44, "OpenGL 4.4")
  TGL_ES_version* = enum
    glesv10 = (glv10, "OpenGL ES 1.0")
    glesv11 = (glv11, "OpenGL ES 1.1")
    glesv20 = (glv20, "OpenGL ES 2.0")
    glesv30 = (glv30, "OpenGL ES 3.0")
  TGL_API_type = enum
    GL_API_GL,
    GL_API_GL_ES
  TGL_API* = object
    case kind: TGL_API_type:
      of GL_API_GL:
        GL_version: TGL_version
        forwardCompat, debugContext: bool
      of GL_API_GL_ES:
        GL_ES_version: TGL_ES_version
    profile: TGL_profile
    robustness: TGL_robustness
  TGL_robustness* = enum
    glrNone = wrapper.NO_ROBUSTNESS,
    glrNoResetNotification = wrapper.NO_RESET_NOTIFICATION,
    glrLoseContextOnReset = wrapper.LOSE_CONTEXT_ON_RESET
  TGL_profile* = enum
    glpAny = wrapper.OPENGL_ANY_PROFILE,
    glpCore = wrapper.OPENGL_CORE_PROFILE,
    glpCompat = wrapper.OPENGL_COMPAT_PROFILE,
  THints = tuple[
    resizable, visible, decorated, stereo, SRGB_capableframebuf: bool,
    bits: TBits,
    accumBufBits: TAccumBufBits,
    nAuxBufs, nMultiSamples, refreshRate: int,
    GL_API: TGL_API]
  TBits = tuple[r, g, b, a, stencil, depth: int]
  TAccumBufBits = tuple[r, g, b, a: int]

proc shouldClose*(o: PWnd): bool =
  wrapper.windowShouldClose(o.handle) != 0

proc `shouldClose=`*(o: PWnd, val: bool) =
  wrapper.setWindowShouldClose(o.handle, val.cint)

proc `title=`*(o: PWnd, val: string) =
  wrapper.setWindowTitle(o.handle, val)

proc pos*(o: PWnd): tuple[x, y: int] =
  var x, y: cint
  wrapper.getWindowPos(o.handle, x.addr, y.addr)
  (x.int, y.int)

proc `pos=`*(o: PWnd, pos: tuple[x, y: int]) =
  wrapper.setWindowPos(o.handle, pos.x.cint, pos.y.cint)

proc size*(o: PWnd): tuple[w, h: int] =
  var x, y: cint
  wrapper.getWindowSize(o.handle, x.addr, y.addr)
  (x.int, y.int)

proc `size=`*(o: PWnd, size: tuple[w, h: int]) =
  wrapper.setWindowSize(o.handle, size.w.cint, size.h.cint)

proc framebufSize*(o: PWnd): tuple[w, h: int] =
  var w, h: cint
  wrapper.getframebufferSize(o.handle, w.addr, h.addr)
  (w.int, h.int)

proc iconify*(o: PWnd) =
  wrapper.iconifyWindow(o.handle)

proc iconified*(o: PWnd): bool =
  wrapper.getWindowAttrib(o.handle, wrapper.ICONIFIED).bool

proc restore*(o: PWnd) =
  wrapper.restoreWindow(o.handle)

proc show*(o: PWnd) =
  wrapper.showWindow(o.handle)

proc hide*(o: PWnd) =
  wrapper.hideWindow(o.handle)

proc visible*(o: PWnd): bool =
  wrapper.getWindowAttrib(o.handle, wrapper.VISIBLE).bool

proc focused*(o: PWnd): bool =
  wrapper.getWindowAttrib(o.handle, wrapper.FOCUSED).bool

proc resizable*(o: PWnd): bool =
  wrapper.getWindowAttrib(o.handle, wrapper.RESIZABLE).bool

proc decorated*(o: PWnd): bool =
  wrapper.getWindowAttrib(o.handle, wrapper.DECORATED).bool
  
proc forwardCompat*(o: PWnd): bool =
  wrapper.getWindowAttrib(o.handle, wrapper.OPENGL_FORWARD_COMPAT).bool

proc debugContext*(o: PWnd): bool =
  wrapper.getWindowAttrib(o.handle, wrapper.OPENGL_DEBUG_CONTEXT).bool

proc profile*(o: PWnd): TGL_profile =
  wrapper.getWindowAttrib(o.handle, wrapper.OPENGL_PROFILE).TGL_profile

proc robustness*(o: PWnd): TGL_robustness =
  wrapper.getWindowAttrib(o.handle, wrapper.CONTEXT_ROBUSTNESS).TGL_robustness

proc stickyKeys*(o: PWnd): bool =
  wrapper.getInputMode(o.handle, wrapper.STICKY_KEYS).bool

proc `stickyKeys=`*(o: PWnd, yes: bool) =
  wrapper.setInputMode(o.handle, wrapper.STICKY_KEYS, yes.cint)

proc stickyMouseBtns*(o: PWnd): bool =
  wrapper.getInputMode(o.handle, wrapper.STICKY_MOUSE_BUTTONS).bool

proc `stickyMouseBtns=`*(o: PWnd, yes: bool) =
  wrapper.setInputMode(o.handle, wrapper.STICKY_MOUSE_BUTTONS, yes.cint)

type
  TCursorMode* = enum
    cmNormal = wrapper.CURSOR_NORMAL
    cmHidden = wrapper.CURSOR_HIDDEN
    cmDisabled = wrapper.CURSOR_DISABLED

proc cursorMode*(o: PWnd): TCursorMode =
  wrapper.getInputMode(o.handle, wrapper.CURSOR).TCursorMode

proc `cursorMode=`*(o: PWnd, mode: TCursorMode) =
  wrapper.setInputMode(o.handle, wrapper.CURSOR, mode.cint)

proc monitor*(o: PWnd): TMonitor =
  newMonitor(wrapper.getWindowMonitor(o.handle))

proc isKeyDown*(o: PWnd, key: TKey): bool =
  wrapper.getKey(o.handle, key.cint) == wrapper.PRESS

proc mouseBtnDown*(o: PWnd, btn: TMouseBtn): bool =
  wrapper.getMouseButton(o.handle, btn.cint) == wrapper.PRESS

proc cursorPos*(o: PWnd): tuple[x, y: float64] =
  var x, y: cdouble
  wrapper.getCursorPos(o.handle, x.addr, y.addr)
  (x.float64, y.float64)

proc `cursorPos=`*(o: PWnd, pos: tuple[x, y: float64]) =
  wrapper.setCursorPos(o.handle, pos.x.cdouble, pos.y.cdouble)

proc isJoystickPresent*(o: PWnd, joy: int): bool =
  wrapper.joystickPresent(joy.cint).bool

proc getJoystickAxes*(joy: int): seq[float32] =
  var count: cint
  var axesPtr = wrapper.getJoystickAxes(joy.cint, count.addr)
  fail(iff = count <= 0)
  var axes = cast[ptr array[count.int - 1, float32]](axesPtr)

  result = @[]
  for i in 0 .. <count:
    result.add(axes[i].float32)

proc getJoystickBtns*(joy: int): seq[string] =
  var count: cint
  var btnsPtr = wrapper.getJoystickButtons(joy.cint, count.addr)
  fail(iff = count <= 0)
  var btns = cast[ptr array[count.int - 1, cstring]](btnsPtr)

  result = @[]
  for i in 0 .. <count:
    result.add($btns[i])

proc joystickName*(joy: int): string =
  $wrapper.getJoystickName(joy.cint)

proc `clipboardStr=`*(o: PWnd, str: string) =
  wrapper.setClipboardString(o.handle, str)

proc clipboardStr*(o: PWnd): string =
  $(wrapper.getClipboardString(o.handle).failIf(nil))

proc major(ver: TGL_version|TGL_ES_version): int =
  ver.int shr 4 and 0xf

proc minor(ver: TGL_version|TGL_ES_version): int =
  ver.int and 0xf

proc initGL_API*(
    version = glv30,
    forwardCompat, debugContext = false,
    profile = glpAny,
    robustness = glrNone): TGL_API =
  TGL_API(kind: GL_API_GL, GL_version: version, forwardCompat: forwardCompat,
    debugContext: debugContext, profile: profile, robustness: robustness)

proc initGL_ES_API*(version = glesv20, profile = glpAny, robustness = glrNone):
    TGL_API =
  TGL_API(kind: GL_API_GL_ES, GL_ES_version: version, profile: profile,
    robustness: robustness)

proc initHints*(
    visible, decorated = true,
    resizable, stereo, SRGB_capableframebuf = false,
    bits: TBits = (8, 8, 8, 8, 8, 24),
    accumBufBits: TAccumBufBits = (0, 0, 0, 0),
    nAuxBufs, nMultiSamples, refreshRate: range[0 .. 1000] = 0,
    GL_API = initGL_API()): THints =
  (resizable, visible, decorated, stereo, SRGB_capableframebuf, bits,
   accumBufBits, nAuxBufs, nMultiSamples, refreshRate, GL_API)

proc setHints(o: THints) =
  proc h(name: cint, val: TOrdinal) =
    wrapper.windowHint(name, val.cint)

  h(wrapper.RESIZABLE, o.resizable)
  h(wrapper.VISIBLE, o.visible)
  h(wrapper.DECORATED, o.decorated)

  h(wrapper.RED_BITS, o.bits.r)
  h(wrapper.GREEN_BITS, o.bits.r)
  h(wrapper.BLUE_BITS, o.bits.r)
  h(wrapper.ALPHA_BITS, o.bits.r)
  h(wrapper.DEPTH_BITS, o.bits.depth)
  h(wrapper.STENCIL_BITS, o.bits.stencil)

  h(wrapper.ACCUM_RED_BITS, o.accumBufBits.r)
  h(wrapper.ACCUM_GREEN_BITS, o.accumBufBits.g)
  h(wrapper.ACCUM_BLUE_BITS, o.accumBufBits.b)
  h(wrapper.ACCUM_ALPHA_BITS, o.accumBufBits.a)

  h(wrapper.AUX_BUFFERS, o.nAuxBufs)
  h(wrapper.STEREO, o.stereo)
  h(wrapper.SAMPLES, o.nMultiSamples)
  h(wrapper.SRGB_CAPABLE, o.SRGB_capableframebuf)
  h(wrapper.REFRESH_RATE, o.refreshRate)

  # OpenGL hints.

  case o.GL_API.kind:
    of GL_API_GL:
      h(wrapper.CONTEXT_VERSION_MAJOR, o.GL_API.GL_version.major)
      h(wrapper.CONTEXT_VERSION_MINOR, o.GL_API.GL_version.minor)

      h(wrapper.CLIENT_API, wrapper.OPENGL_API)
      h(wrapper.OPENGL_FORWARD_COMPAT, o.GL_API.forwardCompat)
      h(wrapper.OPENGL_DEBUG_CONTEXT, o.GL_API.debugContext)
    of GL_API_GL_ES:
      h(wrapper.CONTEXT_VERSION_MAJOR, o.GL_API.GL_ES_version.major)
      h(wrapper.CONTEXT_VERSION_MINOR, o.GL_API.GL_ES_version.minor)

      h(wrapper.CLIENT_API, wrapper.OPENGL_ES_API)

  h(wrapper.OPENGL_PROFILE, o.GL_API.profile)
  h(wrapper.CONTEXT_ROBUSTNESS, o.GL_API.robustness)

proc destroy*(o: PWnd) =
  wrapper.destroyWindow(o.handle)

proc makeContextCurrent(o: PWnd) =
  wrapper.makeContextCurrent(o.handle)

proc newWnd*(
    dim = (w: 640, h: 480),
    title = "",
    hints = initHints(),
    fullscreen = nilMonitor(),
    shareResourcesWith = nilWnd(),
    initLibIfNeeded = true,
    makeContextCurrent = true):
      PWnd =
  new(result)

  if initLibIfNeeded:
    init()

  setHints(hints)
  result.handle = wrapper.createWindow(dim.w.cint, dim.h.cint, title,
    fullscreen.handle, shareResourcesWith.handle).failIf(nil)
  wndTable.add result.handle, result

  if makeContextCurrent:
    result.makeContextCurrent()

  # 
  template get(f: expr): bool =
    var wnd {.inject.} = handleToWnd(handle)
    var cb {.inject.} = if not wnd.isNil: wnd.f else: nil

    not wnd.isNil and not cb.isNil

  wndPosCb = proc(handle: PWndHandle, x, y: cint) {.cdecl.} =
    if get(wndPosCb):
      cb(wnd, (x: x.int, y: y.int))
  discard wrapper.setWindowPosCallback(result.handle, wndPosCb)

  wndSizeCb = proc(handle: PWndHandle, w, h: cint) {.cdecl.} =
    if get(wndSizeCb):
      cb(wnd, (w.Positive, h. Positive))
  discard wrapper.setWindowSizeCallback(result.handle, wndSizeCb)

  wndCloseCb = proc(handle: PWndHandle) {.cdecl.} =
    if get(wndCloseCb):
      cb(wnd)
  discard wrapper.setWindowCloseCallback(result.handle, wndCloseCb)

  wndRefreshCb = proc(handle: PWndHandle) {.cdecl.} =
    if get(wndRefreshCb):
      cb(wnd)
  discard wrapper.setWindowRefreshCallback(result.handle, wndRefreshCb)

  wndFocusCb = proc(handle: PWndHandle, focus: cint) {.cdecl.} =
    if get(wndFocusCb):
      cb(wnd, focus.bool)
  discard wrapper.setWindowFocusCallback(result.handle, wndFocusCb)

  wndIconifyCb = proc(handle: PWndHandle, iconify: cint) {.cdecl.} =
    if get(wndIconifyCb):
      cb(wnd, iconify.bool)
  discard wrapper.setWindowIconifyCallback(result.handle, wndIconifyCb)

  framebufSizeCb = proc(handle: PWndHandle, w, h: cint) {.cdecl.} =
    if get(framebufSizeCb):
      cb(wnd, (w.Positive, h.Positive))
  discard wrapper.setframebufferSizeCallback(result.handle, framebufSizeCb)

  mouseBtnCb = proc(
      handle: PWndHandle, btn, pressed, modKeys: cint) {.cdecl.} =
    if get(mouseBtnCb):
      cb(wnd, TMouseBtn(btn), pressed.bool, initModifierKeySet(modKeys))
  discard wrapper.setMouseButtonCallback(result.handle, mouseBtnCb)

  cursorPosCb = proc(handle: PWndHandle, x, y: cdouble) {.cdecl.} =
    if get(cursorPosCb):
      cb(wnd, (x.float64, y.float64))
  discard wrapper.setCursorPosCallback(result.handle, cursorPosCb)

  cursorEnterCb = proc(handle: PWndHandle, entered: cint) {.cdecl.} =
    if get(cursorEnterCb):
      cb(wnd, entered.bool)
  discard wrapper.setCursorEnterCallback(result.handle, cursorEnterCb)

  scrollCb = proc(handle: PWndHandle, xOffset, yOffset: cdouble) {.cdecl.} =
    if get(scrollCb):
      cb(wnd, (x: xOffset.float64, y: yOffset.float64))
  discard wrapper.setScrollCallback(result.handle, scrollCb)

  keyCb = proc(
      handle: PWndHandle, key, scanCode, action, modKeys: cint) {.cdecl.} =
    if get(keyCb):
      cb(wnd, TKey(key), scanCode.int, action.TKeyAction,
        initModifierKeySet(modKeys))
  discard wrapper.setKeyCallback(result.handle, keyCb)

  charCb = proc(handle: PWndHandle, codePoint: cuint) {.cdecl.} =
    if get(charCb):
      cb(wnd, codePoint.TRune)
  discard wrapper.setCharCallback(result.handle, charCb)

proc `$`*(o: TKey): string =
  result = system.`$`(o)[3 .. -1]
  result[0] = result[0].toLower()

proc swapBufs*(o: PWnd) =
  wrapper.swapBuffers(o.handle)

proc version*: tuple[major, minor, rev: int] =
  var tmp = (0.cint, 0.cint, 0.cint)
  wrapper.getVersion(tmp[0].addr, tmp[1].addr, tmp[2].addr)
  (tmp[0].int, tmp[1].int, tmp[2].int)

proc versionStr*: string =
  $wrapper.getVersionString()

proc update*(o: PWnd) =
  o.swapBufs()
  pollEvents()

proc swapInterval*(interval: Natural) =
  wrapper.swapInterval(interval.cint)
