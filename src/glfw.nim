when cushort isnot uint16:
  {.fatal: "cushort != uint16: " &
    "not binary compatible with glfw. Please report this.".}

when cuint isnot uint32:
  {.fatal: "cuint != uint32: " &
    "not binary compatible with glfw. Please report this.".}

import glfw/wrapper
import tables
from unicode import Rune

export unicode.Rune
export wrapper.pollEvents
export wrapper.waitEvents

converter toInt32Tuple*(t: tuple[w, h: int]): tuple[w, h: int32] =
  (t[0].int32, t[1].int32)

converter toInt32Tuple*(t: tuple[x, y: int]): tuple[x, y: int32] =
  (t[0].int32, t[1].int32)

converter toInt32Tuple*(t: tuple[r, g, b, a: int]): tuple[r, g, b, a: int32] = (t[0].int32, t[1].int32, t[2].int32, t[3].int32)

converter toInt32Tuple*(t: tuple[r, g, b, a, stencil, depth: int]): tuple[r, g, b, a, stencil, depth: int32] =
  (t[0].int32, t[1].int32, t[2].int32, t[3].int32, t[4].int32, t[5].int32)

type
  MouseButton* = enum
    mbLeft = (0, "left mouse button")
    mbRight = (1, "right mouse button")
    mbMiddle = (2, "middle mouse button")
    mb4 = (3, "mouse button 4")
    mb5 = (4, "mouse button 5")
    mb6 = (5, "mouse button 6")
    mb7 = (6, "mouse button 7")
    mb8 = (7, "mouse button 8")
  Key* = enum
    keyUnknown = (-1, "unknown")
    keySpace = (32, "space")
    keyApostrophe = (39, "apostrophe")
    keyComma = (44, "comma")
    keyMinus = (45, "minus")
    keyPeriod = (46, "period")
    keySlash = (47, "slash")
    key0 = (48, "0")
    key1 = (49, "1")
    key2 = (50, "2")
    key3 = (51, "3")
    key4 = (52, "4")
    key5 = (53, "5")
    key6 = (54, "6")
    key7 = (55, "7")
    key8 = (56, "8")
    key9 = (57, "9")
    keySemicolon = (59, "semicolon")
    keyEqual = (61, "equal")
    keyA = (65, "a")
    keyB = (66, "b")
    keyC = (67, "c")
    keyD = (68, "d")
    keyE = (69, "e")
    keyF = (70, "f")
    keyG = (71, "g")
    keyH = (72, "h")
    keyI = (73, "i")
    keyJ = (74, "j")
    keyK = (75, "k")
    keyl = (76, "L")
    keyM = (77, "m")
    keyN = (78, "n")
    keyO = (79, "o")
    keyP = (80, "p")
    keyQ = (81, "q")
    keyR = (82, "r")
    keyS = (83, "s")
    keyT = (84, "t")
    keyU = (85, "u")
    keyV = (86, "v")
    keyW = (87, "w")
    keyX = (88, "x")
    keyY = (89, "y")
    keyZ = (90, "z")
    keyLeftBracket = (91, "left bracket")
    keyBackslash = (92, "backslash")
    keyRightBracket = (93, "right bracket")
    keyGraveAccent = (96, "grave accent")
    keyWorld1 = (161, "world1")
    keyWorld2 = (162, "world2")
    keyEscape = (256, "escape")
    keyEnter = (257, "enter")
    keyTab = (258, "tab")
    keyBackspace = (259, "backspace")
    keyInsert = (260, "insert")
    keyDelete = (261, "delete")
    keyRight = (262, "right")
    keyLeft = (263, "left")
    keyDown = (264, "down")
    keyUp = (265, "up")
    keyPageUp = (266, "page up")
    keyPageDown = (267, "page down")
    keyHome = (268, "home")
    keyEnd = (269, "end")
    keyCapsLock = (280, "caps lock")
    keyScrollLock = (281, "scroll lock")
    keyNumLock = (282, "num lock")
    keyPrintScreen = (283, "print screen")
    keyPause = (284, "pause")
    keyF1 = (290, "f1")
    keyF2 = (291, "f2")
    keyF3 = (292, "f3")
    keyF4 = (293, "f4")
    keyF5 = (294, "f5")
    keyF6 = (295, "f6")
    keyF7 = (296, "f7")
    keyF8 = (297, "f8")
    keyF9 = (298, "f9")
    keyF10 = (299, "f10")
    keyF11 = (300, "f11")
    keyF12 = (301, "f12")
    keyF13 = (302, "f13")
    keyF14 = (303, "f14")
    keyF15 = (304, "f15")
    keyF16 = (305, "f16")
    keyF17 = (306, "f17")
    keyF18 = (307, "f18")
    keyF19 = (308, "f19")
    keyF20 = (309, "f20")
    keyF21 = (310, "f21")
    keyF22 = (311, "f22")
    keyF23 = (312, "f23")
    keyF24 = (313, "f24")
    keyF25 = (314, "f25")
    keyKp0 = (320, "kp0")
    keyKp1 = (321, "kp1")
    keyKp2 = (322, "kp2")
    keyKp3 = (323, "kp3")
    keyKp4 = (324, "kp4")
    keyKp5 = (325, "kp5")
    keyKp6 = (326, "kp6")
    keyKp7 = (327, "kp7")
    keyKp8 = (328, "kp8")
    keyKp9 = (329, "kp9")
    keyKpDecimal = (330, "kp decimal")
    keyKpDivide = (331, "kp divide")
    keyKpMultiply = (332, "kp multiply")
    keyKpSubtract = (333, "kp subtract")
    keyKpAdd = (334, "kp add")
    keyKpEnter = (335, "kp enter")
    keyKpEqual = (336, "kp equal")
    keyLeftShift = (340, "left shift")
    keyLeftControl = (341, "left control")
    keyLeftAlt = (342, "left alt")
    keyLeftSuper = (343, "left super")
    keyRightShift = (344, "right shift")
    keyRightControl = (345, "right control")
    keyRightAlt = (346, "right alt")
    keyRightSuper = (347, "right super")
    keyMenu = (348, "menu")
  KeyAction* = enum
    kaUp = (0, "up")
    kaDown = (1, "down")
    kaRepeat = (2, "repeat")
  ModifierKey* = enum
    mkShift = (wrapper.MOD_SHIFT, "shift")
    mkCtrl = (wrapper.MOD_CONTROL, "ctrl")
    mkAlt = (wrapper.MOD_ALT, "alt")
    mkSuper = (wrapper.MOD_SUPER, "super")

type
  WindowHandle = wrapper.Window
  WindowObj = object
    handle: WindowHandle

    windowPositionCb*: WindowPositionCb
    windowSizeCb*: WindowSizeCb
    windowCloseCb*: WindowCloseCb
    windowRefreshCb*: WindowRefreshCb
    windowFocusCb*: WindowFocusCb
    windowIconifyCb*: WindowIconifyCb
    framebufferSizeCb*: FramebufferSizeCb
    mouseButtonCb*: MouseButtonCb
    cursorPositionCb*: CursorPositionCb
    cursorEnterCb*: CursorEnterCb
    scrollCb*: ScrollCb
    keyCb*: KeyCb
    charCb*: CharCb
  Window* = ref WindowObj
  WindowPositionCb* = proc(window: Window, pos: tuple[x, y: int32]) {.closure.}
  WindowSizeCb* = proc(window: Window, size: tuple[w, h: int32]) {.closure.}
  WindowCloseCb* = proc(window: Window) {.closure.}
  WindowRefreshCb* = proc(window: Window) {.closure.}
  WindowFocusCb* = proc(window: Window, focus: bool) {.closure.}
  WindowIconifyCb* = proc(window: Window, iconified: bool) {.closure.}
  FramebufferSizeCb* = proc(window: Window, res: tuple[w, h: int32]) {.closure.}
  MouseButtonCb* = proc(window: Window, button: MouseButton, pressed: bool,
    modKeys: set[ModifierKey]) {.closure.}
  CursorPositionCb* = proc(window: Window, pos: tuple[x, y: float64]) {.closure.}
  CursorEnterCb* = proc(window: Window, entered: bool) {.closure.}
  ScrollCb* = proc(window: Window, offset: tuple[x, y: float64]) {.closure.}
  KeyCb* = proc(window: Window, key: Key, scanCode: int32, action: KeyAction,
    modKeys: set[ModifierKey]) {.closure.}
  CharCb* = proc(window: Window, codePoint: Rune) {.closure.}
  MonitorHandle = wrapper.Monitor
  Monitor* = object
    handle: MonitorHandle

converter toHandle(m: Monitor): MonitorHandle = m.handle
converter toHandle(w: Window): WindowHandle = w.handle

proc initModifierKeySet(bitfield: int): set[ModifierKey] =
  # XXX: This should not be necessary just because the enum type has
  # non-consecutive elements.
  let mods = [ModifierKey.mkShift, ModifierKey.mkCtrl, ModifierKey.mkAlt, ModifierKey.mkSuper]
  for m in mods:
    let bit = (bitfield.int and m.int)
    if bit != 0:
      result.incl(bit.ModifierKey)

type
  GlfwErrorType* = enum
    getNoError = (wrapper.NOT_INITIALIZED - 2, "no error")
    getUnknownError = (wrapper.NOT_INITIALIZED - 1, "unknown error")
    getNotInitialized = (wrapper.NOT_INITIALIZED, "not initialized")
    getNoCurrentContext = (wrapper.NO_CURRENT_CONTEXT, "no current context")
    getInvalidEnum = (wrapper.INVALID_ENUM, "invalid enum")
    getInvalidValue = (wrapper.INVALID_VALUE, "invalid value")
    getOutOfMemory = (wrapper.OUT_OF_MEMORY, "out of memory")
    getApiUnavailable = (wrapper.API_UNAVAILABLE, "API unavailable")
    getVersionUnavailable = (wrapper.VERSION_UNAVAILABLE, "version unavailable")
    getPlatformError = (wrapper.PLATFORM_ERROR, "platform error")
    getFormattUnavailable = (wrapper.FORMAT_UNAVAILABLE, "format unavailable")

var
  gErrorCode = getNoError
  gErrorMsg = ""

type
  GLFWError* = object of Exception
    error*: GlfwErrorType

proc `$`*(e: GLFWError): string = $e.error
proc getHandle*(w: Window): WindowHandle =
  w.handle

var
  hasInitialized = false

proc fail(error = getUnknownError, msg: string = "", iff = true) =
  if not iff:
    return

  var e = newException(GLFWError, if msg != "": msg else: $error)
  gErrorCode = getNoError
  gErrorMsg.setLen(0)
  e.error = error
  raise e

proc errorCheck =
  if gErrorCode != getNoError:
    fail(gErrorCode, gErrorMsg)
  # This branch handles the case where 'init' has not been called,
  # in which case an error callback has not been registered.
  elif not hasInitialized:
    fail(getNotInitialized, gErrorMsg)

proc failIf[T](val, equals: T): T =
  result = val

  if result == equals:
    errorCheck()

# We can't raise an exception here, because that might mess up the GLFW stack.
proc errorCb(code: int32, msg: cstring) {.cdecl.} =
  gErrorCode = GlfwErrorType(code)
  gErrorMsg = $msg

type
  MonitorCb* = proc(monitor: Monitor, connected: bool) {.closure.}

var gMonitorCb: MonitorCb

proc `monitorCb=`*(cb: MonitorCb) =
  gMonitorCb = cb

proc internalMonitorCb(handle: MonitorHandle, connected: int32) {.cdecl.} =
  if not gMonitorCb.isNil:
    gMonitorCb(Monitor(handle: handle), connected.bool)

proc initialize* =
  if hasInitialized:
    return

  discard wrapper.setErrorCallback(errorCb)
  discard wrapper.init().failIf(0)
  discard wrapper.setMonitorCallback(internalMonitorCb)

  hasInitialized = true

proc terminate* =
  wrapper.terminate()
  hasInitialized = false

proc newMonitor*(handle: MonitorHandle): Monitor =
  result.handle = handle

iterator monitors*: Monitor =
  var count: int32
  var handlesPtr = wrapper.getMonitors(count.addr).failIf(nil)
  fail(iff = count <= 0)
  var handles = cast[ptr array[10_000, MonitorHandle]](handlesPtr)

  for i in 0 .. <count:
    yield newMonitor(handles[i])

proc getPrimaryMonitor*: Monitor =
  newMonitor(wrapper.getPrimaryMonitor().failIf(nil))

proc pos*(m: Monitor): tuple[x, y: int32] =
  wrapper.getMonitorPos(m, result[0].addr, result[1].addr)

proc physicalSizeMM*(m: Monitor): tuple[w, h: int32] =
  wrapper.getMonitorPhysicalSize(m, result[0].addr, result[1].addr)

proc name*(m: Monitor): string =
  $wrapper.getMonitorName(m).failIf(nil)

type
  VideoMode* = object
    size*: tuple[w, h: int32]
    bits*: tuple[r, g, b: int32]
    refreshRate*: int32

# XXX: should be evaluated at compile time
assert VideoMode.sizeof == wrapper.VideoMode.sizeof

iterator videoModes*(m: Monitor): VideoMode =
  var n: int32
  var modesPtr = wrapper.getVideoModes(m, n.addr).failIf(nil)
  fail(iff = n <= 0)

  var modes = cast[ptr array[10_000, wrapper.VideoMode]](modesPtr)
  for i in 0 .. <n:
    yield cast[VideoMode](modes[i])

proc videoMode*(m: Monitor): VideoMode =
  cast[VideoMode](wrapper.getVideoMode(m).failIf(nil))

proc `gamma=`*(m: Monitor, val: float32) =
  wrapper.setGamma(m, val.cfloat)

type
  GammaRamp* = tuple[r, g, b: seq[uint16], size: int32]
  GammaRampPtr* = ptr GammaRamp

proc `gammaRamp=`*(m: Monitor, ramp: GammaRamp) =
  wrapper.setGammaRamp(m, cast[ptr wrapper.GammaRamp](ramp.unsafeAddr))

proc gammaRamp*(m: Monitor): GammaRampPtr =
  cast[GammaRampPtr](wrapper.getGammaRamp(m).failIf(nil))

proc nilMonitor*: Monitor =
  discard

proc nilWindow*: Window =
  new(result)

var gWindowTable = initTable[WindowHandle, Window]()
#gWindowTable[nil] = nil

var
  windowPositionCb: wrapper.Windowposfun
  windowSizeCb: wrapper.Windowsizefun
  windowCloseCb: wrapper.Windowclosefun
  windowRefreshCb: wrapper.Windowrefreshfun
  windowFocusCb: wrapper.Windowfocusfun
  windowIconifyCb: wrapper.Windowiconifyfun
  framebufferSizeCb: wrapper.Framebuffersizefun
  mouseButtonCb: wrapper.MouseButtonfun
  cursorPositionCb: wrapper.Cursorposfun
  cursorEnterCb: wrapper.Cursorenterfun
  scrollCb: wrapper.Scrollfun
  keyCb: wrapper.Keyfun
  charCb: wrapper.Charfun

type
  OpenglVersion* = enum
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
  OpenglEsVersion* = enum
    glesv10 = (glv10, "OpenGL ES 1.0")
    glesv11 = (glv11, "OpenGL ES 1.1")
    glesv20 = (glv20, "OpenGL ES 2.0")
    glesv30 = (glv30, "OpenGL ES 3.0")
  OpenglApiType* = enum
    apiOpengl,
    apiOpenglEs
  OpenglApi* = object
    case kind*: OpenglApiType
      of apiOpengl:
        openglVersion*: OpenglVersion
        forwardCompat*, debugContext*: bool
      of apiOpenglEs:
        openglEsVersion*: OpenglEsVersion
    profile*: GlProfile
    robustness*: GlRobustness
  GlRobustness* = enum
    glrNone = wrapper.NO_ROBUSTNESS,
    glrNoResetNotification = wrapper.NO_RESET_NOTIFICATION,
    glrLoseContextOnReset = wrapper.LOSE_CONTEXT_ON_RESET
  GlProfile* = enum
    glpAny = wrapper.OPENGL_ANY_PROFILE,
    glpCore = wrapper.OPENGL_CORE_PROFILE,
    glpCompat = wrapper.OPENGL_COMPAT_PROFILE,

proc shouldClose*(w: Window): bool =
  wrapper.windowShouldClose(w).bool

proc `shouldClose=`*(w: Window, val: bool) =
  wrapper.setWindowShouldClose(w, val.int32)

proc `title=`*(w: Window, val: string) =
  wrapper.setWindowTitle(w, val)

proc pos*(w: Window): tuple[x, y: int32] =
  wrapper.getWindowPos(w, result.x.addr, result.y.addr)

proc `pos=`*(w: Window, pos: tuple[x, y: int32]) =
  wrapper.setWindowPos(w, pos.x, pos.y)

proc size*(w: Window): tuple[w, h: int32] =
  wrapper.getWindowSize(w, result.w.addr, result.h.addr)

proc `size=`*(w: Window, size: tuple[w, h: int32]) =
  wrapper.setWindowSize(w, size.w, size.h)

proc framebufferSize*(w: Window): tuple[w, h: int32] =
  wrapper.getframebufferSize(w, result.w.addr, result.h.addr)

proc iconify*(w: Window) =
  wrapper.iconifyWindow(w)

proc iconified*(w: Window): bool =
  wrapper.getWindowAttrib(w, wrapper.ICONIFIED).bool

proc restore*(w: Window) =
  wrapper.restoreWindow(w)

proc show*(w: Window) =
  wrapper.showWindow(w)

proc hide*(w: Window) =
  wrapper.hideWindow(w)

proc visible*(w: Window): bool =
  wrapper.getWindowAttrib(w, wrapper.VISIBLE).bool

proc focused*(w: Window): bool =
  wrapper.getWindowAttrib(w, wrapper.FOCUSED).bool

proc resizable*(w: Window): bool =
  wrapper.getWindowAttrib(w, wrapper.RESIZABLE).bool

proc decorated*(w: Window): bool =
  wrapper.getWindowAttrib(w, wrapper.DECORATED).bool

proc forwardCompat*(w: Window): bool =
  wrapper.getWindowAttrib(w, wrapper.OPENGL_FORWARD_COMPAT).bool

proc debugContext*(w: Window): bool =
  wrapper.getWindowAttrib(w, wrapper.OPENGL_DEBUG_CONTEXT).bool

proc profile*(w: Window): GlProfile =
  wrapper.getWindowAttrib(w, wrapper.OPENGL_PROFILE).GlProfile

proc robustness*(w: Window): GlRobustness =
  wrapper.getWindowAttrib(w, wrapper.CONTEXT_ROBUSTNESS).GlRobustness

proc stickyKeys*(w: Window): bool =
  wrapper.getInputMode(w, wrapper.STICKY_KEYS).bool

proc `stickyKeys=`*(w: Window, yes: bool) =
  wrapper.setInputMode(w, wrapper.STICKY_KEYS, yes.int32)

proc stickyMouseButtons*(w: Window): bool =
  wrapper.getInputMode(w, wrapper.STICKY_MOUSE_BUTTONS).bool

proc `stickyMouseButtons=`*(w: Window, yes: bool) =
  wrapper.setInputMode(w, wrapper.STICKY_MOUSE_BUTTONS, yes.int32)

type
  CursorMode* = enum
    cmNormal = wrapper.CURSOR_NORMAL
    cmHidden = wrapper.CURSOR_HIDDEN
    cmDisabled = wrapper.CURSOR_DISABLED

proc cursorMode*(w: Window): CursorMode =
  wrapper.getInputMode(w, wrapper.CURSOR).CursorMode

proc `cursorMode=`*(w: Window, mode: CursorMode) =
  wrapper.setInputMode(w, wrapper.CURSOR, mode.int32)

proc monitor*(w: Window): Monitor =
  newMonitor(wrapper.getWindowMonitor(w))

proc isKeyDown*(w: Window, key: Key): bool =
  wrapper.getKey(w, key.int32) == wrapper.PRESS

proc mouseButtonDown*(w: Window, button: MouseButton): bool =
  wrapper.getMouseButton(w, button.int32) == wrapper.PRESS

proc cursorPos*(w: Window): tuple[x, y: float64] =
  wrapper.getCursorPos(w, result.x.addr, result.y.addr)

proc `cursorPos=`*(w: Window, pos: tuple[x, y: float64]) =
  wrapper.setCursorPos(w, pos.x.cdouble, pos.y.cdouble)

proc isJoystickPresent*(w: Window, joy: int32): bool =
  wrapper.joystickPresent(joy).bool

iterator joystickAxes*(joy: int32): float32 =
  var count: int32
  var axesPtr = wrapper.getJoystickAxes(joy, count.addr)
  fail(iff = count <= 0)
  var axes = cast[ptr array[10_000, float32]](axesPtr)

  for i in 0 .. <count:
    yield axes[i]

iterator getJoystickButtons*(joy: int32): string =
  var count: int32
  var buttonPtr = wrapper.getJoystickButtons(joy, count.addr)
  fail(iff = count <= 0)
  var buttons = cast[ptr array[10_000, cstring]](buttonPtr)

  for i in 0 .. <count:
    yield $buttons[i]

proc joystickName*(joy: int32): string =
  $wrapper.getJoystickName(joy)

proc `clipboardString=`*(w: Window, str: string) =
  wrapper.setClipboardString(w, str)

proc clipboardString*(w: Window): string =
  $(wrapper.getClipboardString(w).failIf(nil))

proc major(ver: OpenglVersion|OpenglEsVersion): int =
  ver.int shr 4 and 0xf

proc minor(ver: OpenglVersion|OpenglEsVersion): int =
  ver.int and 0xf

proc initOpenGlApi*(version = glv20, forwardCompat, debugContext = false,
    profile = glpAny, robustness = glrNone): OpenglApi =
  OpenglApi(kind: apiOpengl, openglVersion: version,
            forwardCompat: forwardCompat, debugContext: debugContext,
            profile: profile, robustness: robustness)

proc initOpenGlEsApi*(version = glesv20, profile = glpAny,
                      robustness = glrNone): OpenglApi =
  OpenglApi(kind: apiOpenglEs, openglEsVersion: version, profile: profile,
            robustness: robustness)

proc setHints(
      resizable, visible, decorated, stereo, srgbCapableFramebuffer: bool,
      bits: tuple[r, g, b, a, stencil, depth: int32],
      accumBufferBits: tuple[r, g, b, a: int32],
      nAuxBuffers, nMultiSamples, refreshRate: int32,
      openglApi: OpenglApi) =
  template h(name, val: untyped) = wrapper.windowHint(name.int32, val.int32)

  h(wrapper.RESIZABLE, resizable)
  h(wrapper.VISIBLE, visible)
  h(wrapper.DECORATED, decorated)

  h(wrapper.RED_BITS, bits.r)
  h(wrapper.GREEN_BITS, bits.r)
  h(wrapper.BLUE_BITS, bits.r)
  h(wrapper.ALPHA_BITS, bits.r)
  h(wrapper.DEPTH_BITS, bits.depth)
  h(wrapper.STENCIL_BITS, bits.stencil)

  h(wrapper.ACCUM_RED_BITS, accumBufferBits.r)
  h(wrapper.ACCUM_GREEN_BITS, accumBufferBits.g)
  h(wrapper.ACCUM_BLUE_BITS, accumBufferBits.b)
  h(wrapper.ACCUM_ALPHA_BITS, accumBufferBits.a)

  h(wrapper.AUX_BUFFERS, nAuxBuffers)
  h(wrapper.STEREO, stereo)
  h(wrapper.SAMPLES, nMultiSamples)
  h(wrapper.SRGB_CAPABLE, srgbCapableFramebuffer)
  h(wrapper.REFRESH_RATE, refreshRate)

  # OpenGL hints.

  case openglApi.kind:
    of apiOpengl:
      h(wrapper.CONTEXT_VERSION_MAJOR, openglApi.openglVersion.major)
      h(wrapper.CONTEXT_VERSION_MINOR, openglApi.openglVersion.minor)

      h(wrapper.CLIENT_API, wrapper.OPENGL_API)
      h(wrapper.OPENGL_FORWARD_COMPAT, openglApi.forwardCompat)
      h(wrapper.OPENGL_DEBUG_CONTEXT, openglApi.debugContext)
    of apiOpenglEs:
      h(wrapper.CONTEXT_VERSION_MAJOR, openglApi.openglEsVersion.major)
      h(wrapper.CONTEXT_VERSION_MINOR, openglApi.openglEsVersion.minor)

      h(wrapper.CLIENT_API, wrapper.OPENGL_ES_API)

  h(wrapper.OPENGL_PROFILE, openglApi.profile)
  h(wrapper.CONTEXT_ROBUSTNESS, openglApi.robustness)

proc newWindow*(handle: WindowHandle): Window =
  Window(handle: handle)

proc destroy*(w: Window) =
  wrapper.destroyWindow(w)
  gWindowTable.del(w)

proc makeContextCurrent*(w: Window) =
  wrapper.makeContextCurrent(w)

proc currentContext*(): Window =
  newWindow wrapper.getCurrentContext()

proc newWindowImpl(
    size: tuple[w, h: int32],
    title: string,
    fullscreen: Monitor,
    shareResourcesWith: Window,
    visible, decorated, resizable, stereo, srgbCapableFramebuffer: bool,
    bits: tuple[r, g, b, a, stencil, depth: int32],
    accumBufferBits: tuple[r, g, b, a: int32],
    nAuxBuffers, nMultiSamples, refreshRate: int32,
    openglApi: OpenglApi,
    shouldMakeContextCurrent: bool): Window =
  new(result)

  setHints(
    resizable = resizable,
    visible = visible,
    decorated = decorated,
    stereo = stereo,
    srgbCapableFramebuffer = srgbCapableFramebuffer,
    bits = bits,
    accumBufferBits = accumBufferBits,
    nAuxBuffers = nAuxBuffers,
    nMultiSamples = nMultiSamples,
    refreshRate = refreshRate,
    openglApi = openglApi)

  result.handle = wrapper.createWindow(size.w, size.h, title,
    fullscreen, shareResourcesWith).failIf(nil)
  gWindowTable.add result.handle, result

  if shouldMakeContextCurrent:
    result.makeContextCurrent()

  template get(f: untyped): bool =
    var win {.inject.} = gWindowTable.getOrDefault(handle)
    var cb {.inject.} = if not win.isNil: win.f else: nil

    not cb.isNil

  windowPositionCb = proc(handle: WindowHandle, x, y: int32) {.cdecl.} =
    if get(windowPositionCb):
      cb(win, (x: x, y: y))
  discard wrapper.setWindowPosCallback(result, windowPositionCb)

  windowSizeCb = proc(handle: WindowHandle, w, h: int32) {.cdecl.} =
    if get(windowSizeCb):
      cb(win, (w, h))
  discard wrapper.setWindowSizeCallback(result, windowSizeCb)

  windowCloseCb = proc(handle: WindowHandle) {.cdecl.} =
    if get(windowCloseCb):
      cb(win)
  discard wrapper.setWindowCloseCallback(result, windowCloseCb)

  windowRefreshCb = proc(handle: WindowHandle) {.cdecl.} =
    if get(windowRefreshCb):
      cb(win)
  discard wrapper.setWindowRefreshCallback(result, windowRefreshCb)

  windowFocusCb = proc(handle: WindowHandle, focus: int32) {.cdecl.} =
    if get(windowFocusCb):
      cb(win, focus.bool)
  discard wrapper.setWindowFocusCallback(result, windowFocusCb)

  windowIconifyCb = proc(handle: WindowHandle, iconify: int32) {.cdecl.} =
    if get(windowIconifyCb):
      cb(win, iconify.bool)
  discard wrapper.setWindowIconifyCallback(result, windowIconifyCb)

  framebufferSizeCb = proc(handle: WindowHandle, w, h: int32) {.cdecl.} =
    if get(framebufferSizeCb):
      cb(win, (w, h))
  discard wrapper.setframebufferSizeCallback(result, framebufferSizeCb)

  mouseButtonCb = proc(
      handle: WindowHandle, button, pressed, modKeys: int32) {.cdecl.} =
    if get(mouseButtonCb):
      cb(win, MouseButton(button), pressed.bool, initModifierKeySet(modKeys))
  discard wrapper.setMouseButtonCallback(result, mouseButtonCb)

  cursorPositionCb = proc(handle: WindowHandle, x, y: cdouble) {.cdecl.} =
    if get(cursorPositionCb):
      cb(win, (x.float64, y.float64))
  discard wrapper.setCursorPosCallback(result, cursorPositionCb)

  cursorEnterCb = proc(handle: WindowHandle, entered: int32) {.cdecl.} =
    if get(cursorEnterCb):
      cb(win, entered.bool)
  discard wrapper.setCursorEnterCallback(result, cursorEnterCb)

  scrollCb = proc(handle: WindowHandle, xOffset, yOffset: cdouble) {.cdecl.} =
    if get(scrollCb):
      cb(win, (x: xOffset.float64, y: yOffset.float64))
  discard wrapper.setScrollCallback(result, scrollCb)

  keyCb = proc(
      handle: WindowHandle, key, scanCode, action, modKeys: int32) {.cdecl.} =
    if get(keyCb):
      cb(win, Key(key), scanCode, action.KeyAction,
        initModifierKeySet(modKeys))
  discard wrapper.setKeyCallback(result, keyCb)

  charCb = proc(handle: WindowHandle, codePoint: cuint) {.cdecl.} =
    if get(charCb):
      cb(win, codePoint.Rune)
  discard wrapper.setCharCallback(result, charCb)

type
  WindowConfig* = object
    size*: tuple[w, h: int32]
    title*: string
    fullscreen*: Monitor
    shareResourcesWith*: Window
    visible*, decorated*, resizable*, stereo*, srgbCapableFramebuffer*: bool
    bits*: tuple[r, g, b, a, stencil, depth: int32]
    accumBufferBits*: tuple[r, g, b, a: int32]
    nAuxBuffers*, nMultiSamples*, refreshRate*: int32
    openglApi*: OpenglApi

proc initDefaultOpenglWindowConfig*: WindowConfig =
    result = WindowConfig(
      size: (w: 640'i32, h: 480'i32),
      title: "nim-GLFW window",
      fullscreen: nilMonitor(),
      shareResourcesWith: nilWindow(),
      visible: true,
      decorated: true,
      resizable: false,
      stereo: false,
      srgbCapableFramebuffer: false,
      bits: (8'i32, 8'i32, 8'i32, 8'i32, 8'i32, 24'i32),
      accumBufferBits: (8'i32, 8'i32, 8'i32, 8'i32),
      nAuxBuffers: 0,
      nMultiSamples: 0,
      refreshRate: 0,
      openglApi: initOpenGlApi(
        glv20,
        forwardCompat = false,
        debugContext = false,
        glpAny,
        glrNone))

proc initDefaultOpenglEsWindowConfig*: WindowConfig =
    result = WindowConfig(
      size: (w: 640'i32, h: 480'i32),
      title: "nim-GLFW window",
      fullscreen: nilMonitor(),
      shareResourcesWith: nilWindow(),
      visible: true,
      decorated: true,
      resizable: false,
      stereo: false,
      srgbCapableFramebuffer: false,
      bits: (8'i32, 8'i32, 8'i32, 8'i32, 8'i32, 24'i32),
      accumBufferBits: (8'i32, 8'i32, 8'i32, 8'i32),
      nAuxBuffers: 0,
      nMultiSamples: 0,
      refreshRate: 0,
      openglApi: initOpenGlEsApi(
        glesv20,
        glpAny,
        glrNone))

proc newWindow*(config = initDefaultOpenglWindowConfig(),
                makeContextCurrent = true): Window =
  newWindowImpl(
    config.size,
    config.title,
    config.fullscreen,
    config.shareResourcesWith,
    config.visible,
    config.decorated,
    config.resizable,
    config.stereo,
    config.srgbCapableFramebuffer,
    config.bits,
    config.accumBufferBits,
    config.nAuxBuffers,
    config.nMultiSamples,
    config.refreshRate,
    config.openglApi,
    makeContextCurrent)

proc newOpenglWindow*(
    size = (w: 640'i32, h: 480'i32),
    title = "GLFW window",
    fullscreen = nilMonitor(),
    shareResourcesWith = nilWindow(),
    visible, decorated = true,
    resizable, stereo, srgbCapableFramebuffer = false,
    bits: tuple[r, g, b, a, stencil, depth: int32] = (8'i32, 8'i32, 8'i32, 8'i32, 8'i32, 24'i32),
    accumBufferBits: tuple[r, g, b, a: int32] = (8'i32, 8'i32, 8'i32, 8'i32),
    nAuxBuffers, nMultiSamples, refreshRate = 0'i32,
    version = glv20,
    forwardCompat, debugContext = false,
    profile = glpAny,
    robustness = glrNone,
    makeContextCurrent = true): Window =
  result = newWindowImpl(
    size,
    title,
    fullscreen,
    shareResourcesWith,
    visible,
    decorated,
    resizable,
    stereo,
    srgbCapableFramebuffer,
    bits,
    accumBufferBits,
    nAuxBuffers,
    nMultiSamples,
    refreshRate,
    initOpenGlApi(version, forwardCompat, debugContext, profile, robustness),
    makeContextCurrent,
  )

proc newOpenglEsWindow*(
    size = (w: 640'i32, h: 480'i32),
    title = "GLFW window",
    fullscreen = nilMonitor(),
    shareResourcesWith = nilWindow(),
    visible, decorated = true,
    resizable, stereo, srgbCapableFramebuffer = false,
    bits: tuple[r, g, b, a, stencil, depth: int32] = (8'i32, 8'i32, 8'i32, 8'i32, 8'i32, 24'i32),
    accumBufferBits: tuple[r, g, b, a: int32] = (8'i32, 8'i32, 8'i32, 8'i32),
    nAuxBuffers, nMultiSamples, refreshRate = 0'i32,
    version = glesv20,
    profile = glpAny,
    robustness = glrNone,
    makeContextCurrent = true): Window =
  result = newWindowImpl(
    size,
    title,
    fullscreen,
    shareResourcesWith,
    visible,
    decorated,
    resizable,
    stereo,
    srgbCapableFramebuffer,
    bits,
    accumBufferBits,
    nAuxBuffers,
    nMultiSamples,
    refreshRate,
    initOpenGlEsApi(version, profile, robustness),
    makeContextCurrent
  )

proc swapBuffers*(w: Window) =
  wrapper.swapBuffers(w)

proc version*: tuple[major, minor, rev: int32] =
  wrapper.getVersion(result[0].addr, result[1].addr, result[2].addr)

proc versionString*: string =
  $wrapper.getVersionString()

proc swapInterval*(interval: Natural) =
  wrapper.swapInterval(interval.int32)

template getTime*(): float64 =
  wrapper.getTime()

template setTime*(time: float64) =
  wrapper.setTime(time)
