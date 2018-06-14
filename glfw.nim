import glfw/wrapper
import tables
import options
from unicode import Rune

discard setWindowUserPointer
discard getWindowUserPointer
discard defaultWindowHints

export options
export unicode.Rune
export wrapper.pollEvents
export wrapper.waitEvents
export wrapper.postEmptyEvent
export wrapper.createCursor
export wrapper.createStandardCursor
export wrapper.setCursor
export wrapper.destroyCursor
export wrapper.Cursor
export wrapper.Image
export wrapper.MouseButton
export wrapper.mbLeft
export wrapper.mbRight
export wrapper.mbMiddle
export wrapper.ModifierKey
export wrapper.Key
export wrapper.KeyAction
export wrapper.OpenglProfile
export wrapper.ContextReleaseBehavior
export wrapper.ContextCreationApi
export wrapper.ContextRobustness
export wrapper.swapBuffers
export wrapper.getProcAddress
export wrapper.CursorMode

converter toInt32Tuple*(t: tuple[w, h: int]): tuple[w, h: int32] =
  (t[0].int32, t[1].int32)

converter toInt32Tuple*(t: tuple[x, y: int]): tuple[x, y: int32] =
  (t[0].int32, t[1].int32)

converter toInt32Tuple*(t: tuple[r, g, b, a: int]): tuple[r, g, b, a: Option[int32]] =
  (some(t[0].int32), some(t[1].int32), some(t[2].int32), some(t[3].int32))

converter toInt32Tuple*(t: tuple[r, g, b, a, stencil, depth: int]):
    tuple[r, g, b, a, stencil, depth: Option[int32]] =
  (some(t[0].int32), some(t[1].int32), some(t[2].int32), some(t[3].int32), some(t[4].int32), some(t[5].int32))
  
converter toInt32(h: wrapper.Hint): int32 =
  h.int32

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
    charModsCb*: CharModsCb
    dropCb*: DropCb
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
  CharModsCb* = proc(
    window: Window, codepoint: Rune, modkeys: set[ModifierKey]) {.closure.}
  DropCb* = proc(window: Window, paths: PathDropInfo) {.closure.}
  MonitorHandle = wrapper.Monitor
  Monitor* = object
    handle: MonitorHandle
  PathDropInfo* = object
    paths: cstringArray
    len: int32

proc initPathDropInfo(paths: cstringArray, len: int32): PathDropInfo =
  PathDropInfo(paths: paths, len: len)
    
proc len*(p: PathDropInfo): cint =
  p.len

iterator items*(p: PathDropInfo): cstring =
  for i in 0 .. p.len - 1:
    yield p.paths[i]

iterator pairs*(p: PathDropInfo): (int32, cstring) =
  for i in 0 .. p.len - 1:
    yield (i, p.paths[i])

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
  ErrorType* {.size: int32.sizeof.} = enum
    getNoError = (0, "no error")
    getUnknownError = (1, "unknown error")
    getNotInitialized = (0x00010001, "not initialized")
    getNoCurrentContext = (0x00010002, "no current context")
    getInvalidEnum = (0x00010003, "invalid enum")
    getInvalidValue = (0x00010004, "invalid value")
    getOutOfMemory = (0x00010005, "out of memory")
    getApiUnavailable = (0x00010006, "API unavailable")
    getVersionUnavailable = (0x00010007, "version unavailable")
    getPlatformError = (0x00010008, "platform error")
    getFormatUnavailable = (0x00010009, "format unavailable")
    getNoWindowContext = (0x0001000A, "no window context")
      
var
  gErrorCode = getNoError
  gErrorMsg = ""
  hasInitialized = false

type
  GLFWError* = object of Exception
    error*: ErrorType

proc `$`*(e: GLFWError): string = $e.error
proc getHandle*(w: Window): WindowHandle =
  w.handle

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
  gErrorCode = ErrorType(code)
  gErrorMsg = $msg

type
  MonitorCb* = proc(monitor: Monitor, connected: bool) {.closure.}
  JoystickCb* = proc(joystick: int32, connected: bool) {.closure.}

var
  gMonitorCb: MonitorCb
  gJoystickCb: JoystickCb

proc setMonitorCb*(cb: MonitorCb) =
  gMonitorCb = cb

proc setJoystickCb*(cb: JoystickCb) =
  gJoystickCb = cb

proc internalMonitorCb(handle: MonitorHandle, connection: int32) {.cdecl.} =
  if not gMonitorCb.isNil:
    let c = connection.MonitorConnection
    case c
    of mcConnected, mcDisconnected:
        discard

    gMonitorCb(Monitor(handle: handle), c == mcConnected)

proc internalJoystickCb(joy, connected: int32) {.cdecl.} =
  if not gJoystickCb.isNil:
    gJoystickCb(joy, connected.bool)

proc initialize* =
  if hasInitialized:
    return

  discard wrapper.setErrorCallback(errorCb)
  discard wrapper.init().failIf(0)
  discard wrapper.setMonitorCallback(internalMonitorCb)
  discard wrapper.setJoystickCallback(internalJoystickCb)

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

  for i in 0 .. count - 1:
    yield newMonitor(handles[i])

proc getPrimaryMonitor*: Monitor =
  newMonitor(wrapper.getPrimaryMonitor().failIf(nil))

proc pos*(m: Monitor): tuple[x, y: int32] =
  wrapper.getMonitorPos(m, result[0].addr, result[1].addr)

proc physicalSizeMM*(m: Monitor): tuple[w, h: int32] =
  wrapper.getMonitorPhysicalSize(m, result[0].addr, result[1].addr)

proc name*(m: Monitor): cstring =
  wrapper.getMonitorName(m).failIf(nil)

type
  VideoModeObj* = object
    size*: tuple[w, h: int32]
    bits*: tuple[r, g, b: int32]
    refreshRate*: int32
  VideoMode* = ptr VideoModeObj

# XXX: should be evaluated at compile time
assert VideoModeObj.sizeof == wrapper.VideoModeObj.sizeof

iterator videoModes*(m: Monitor): VideoMode =
  var n: int32
  var modesPtr = wrapper.getVideoModes(m, n.addr).failIf(nil)
  fail(iff = n <= 0)

  var modes = cast[ptr array[10_000, wrapper.VideoMode]](modesPtr)
  for i in 0 .. n - 1:
    yield cast[VideoMode](modes[i])

proc videoMode*(m: Monitor): VideoMode =
  cast[VideoMode](wrapper.getVideoMode(m).failIf(nil))

proc `gamma=`*(m: Monitor, val: float32) =
  wrapper.setGamma(m, val.cfloat)

type
  GammaRamp* = tuple[r, g, b: seq[uint16], size: int32]
  GammaRampPtr* = ptr GammaRamp

proc `gammaRamp=`*(m: Monitor, ramp: GammaRamp) =
  wrapper.setGammaRamp(m, cast[wrapper.GammaRamp](ramp.unsafeAddr))

proc gammaRamp*(m: Monitor): GammaRampPtr =
  cast[GammaRampPtr](wrapper.getGammaRamp(m).failIf(nil))

const NoMonitor* = Monitor()

var gWindowTable = initTable[WindowHandle, Window]()

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
  charModsCb: wrapper.Charmodsfun
  dropCb: wrapper.Dropfun

type
  OpenglVersion* = enum
    glv10 = (0x100, "OpenGL 1.0")
    glv11 = (0x110, "OpenGL 1.1")
    glv12 = (0x120, "OpenGL 1.2")
    glv121 = (0x121, "OpenGL 1.2.1")
    glv13 = (0x130, "OpenGL 1.3")
    glv14 = (0x140, "OpenGL 1.4")
    glv15 = (0x150, "OpenGL 1.5")
    glv20 = (0x200, "OpenGL 2.0")
    glv21 = (0x210, "OpenGL 2.1")
    glv30 = (0x300, "OpenGL 3.0")
    glv31 = (0x310, "OpenGL 3.1")
    glv32 = (0x320, "OpenGL 3.2")
    glv33 = (0x330, "OpenGL 3.3")
    glv40 = (0x400, "OpenGL 4.0")
    glv41 = (0x410, "OpenGL 4.1")
    glv42 = (0x420, "OpenGL 4.2")
    glv43 = (0x430, "OpenGL 4.3")
    glv44 = (0x440, "OpenGL 4.4")
    glv45 = (0x450, "OpenGL 4.5")
    glv46 = (0x460, "OpenGL 4.6")
  OpenglEsVersion* = enum
    glesv10 = (0x100, "OpenGL ES 1.0")
    glesv11 = (0x110, "OpenGL ES 1.1")
    glesv20 = (0x200, "OpenGL ES 2.0")
    glesv30 = (0x300, "OpenGL ES 3.0")
    glesv31 = (0x310, "OpenGL ES 3.1")
    glesv32 = (0x320, "OpenGL ES 3.2")

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

proc windowFrameSize*(w: Window): tuple[left, top, right, bottom: int32] =
  wrapper.getWindowFrameSize(w, result.left.addr, result.top.addr,
    result.right.addr, result.bottom.addr)

template windowOp(name: untyped) =
  proc name*(w: Window) =
    `name Window`(w)

windowOp(iconify)
windowOp(restore)
windowOp(show)
windowOp(hide)
windowOp(focus)
windowOp(maximize)

template defWindowAttrib(name: untyped, id: int32, T: typedesc) =
  proc name*(w: Window): T =
    wrapper.getWindowAttrib(w, id).T

defWindowAttrib(visible, hVisible, bool)
defWindowAttrib(focused, hFocused, bool)
defWindowAttrib(iconified, Iconified, bool)
defWindowAttrib(maximized, hMaximized, bool)
defWindowAttrib(resizable, hResizable, bool)
defWindowAttrib(decorated, hDecorated, bool)
defWindowAttrib(floating, hFloating, bool)
defWindowAttrib(clientApi, hClientApi, ClientApi)
defWindowAttrib(contextCreationApi, hContextCreationApi, ContextCreationApi)
defWindowAttrib(contextVersionMajor, hContextVersionMajor, int)
defWindowAttrib(contextVersionMinor, hContextVersionMinor, int)
defWindowAttrib(contextRevision, hContextRevision, int)
defWindowAttrib(openglForwardCompat, hOpenglForwardCompat, bool)
defWindowAttrib(openglDebugContext, hOpenglDebugContext, bool)
defWindowAttrib(openglProfile, hOpenglProfile, OpenglProfile)
defWindowAttrib(contextRobustness, hContextRobustness, ContextRobustness)

template defInputMode(name: untyped, id: int32, T: typedesc) =
  proc name*(w: Window): T =
    wrapper.getInputMode(w, id).T

  proc `name=`*(w: Window, v: T) =
    wrapper.setInputMode(w, id, v.int32)

defInputMode(stickyKeys, wrapper.StickyKeys, bool)
defInputMode(stickyMouseButtons, wrapper.StickyMouseButtons, bool)
defInputMode(cursorMode, wrapper.CursorModeConst, wrapper.CursorMode)

proc monitor*(w: Window): Monitor =
  newMonitor(wrapper.getWindowMonitor(w))

proc `monitor=`*(w: Window, monitor: Monitor; xpos, ypos, width, height, refreshRate: int32) =
  wrapper.setWindowMonitor(w, monitor, xpos, ypos, width, height, refreshRate)

proc isKeyDown*(w: Window, key: Key): bool =
  wrapper.getKey(w, key.int32).KeyAction == kaDown

proc mouseButtonDown*(w: Window, button: MouseButton): bool =
  wrapper.getMouseButton(w, button.int32).KeyAction == kaDown

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

  for i in 0 .. count - 1:
    yield axes[i]

iterator getJoystickButtons*(joy: int32): cstring =
  var count: int32
  var buttonPtr = wrapper.getJoystickButtons(joy, count.addr)
  fail(iff = count <= 0)
  var buttons = cast[ptr array[10_000, cstring]](buttonPtr)

  for i in 0 .. count - 1:
    yield buttons[i]

proc joystickName*(joy: int32): cstring =
  wrapper.getJoystickName(joy)

proc `clipboardString=`*(w: Window, str: string) =
  wrapper.setClipboardString(w, str)

proc clipboardString*(w: Window): cstring =
  wrapper.getClipboardString(w).failIf(nil)

proc major*(ver: OpenglVersion|OpenglEsVersion): int =
  ver.int shr 8 and 0xf

proc minor*(ver: OpenglVersion|OpenglEsVersion): int =
  ver.int shr 4 and 0xf

proc revision*(ver: OpenglVersion|OpenglEsVersion): int =
  ver.int and 0xf

type
  OpenglWindowConfig* = object
    size*: tuple[w, h: int32]
    title*: string
    fullscreenMonitor*: Monitor
    shareResourcesWith*: Window
    visible*, focused*, decorated*, resizable*, stereo*,
      srgbCapableFramebuffer*, floating*, maximized*, autoIconify*,
      doubleBuffer*, forwardCompat*, debugContext*, makeContextCurrent*: bool
    bits*: tuple[r, g, b, a, stencil, depth: Option[int32]]
    accumBufferBits*: tuple[r, g, b, a: Option[int32]]
    nAuxBuffers*, nMultiSamples*: int32
    refreshRate*: Option[int32]
    contextReleaseBehavior*: ContextReleaseBehavior
    contextRobustness*: ContextRobustness
    contextCreationApi*: ContextCreationApi
    version*: OpenglVersion
    profile*: OpenglProfile
    contextNoError*: bool
  OpenglEsWindowConfig* = object
    size*: tuple[w, h: int32]
    title*: string
    fullscreenMonitor*: Monitor
    shareResourcesWith*: Window
    visible*, focused*, decorated*, resizable*, stereo*,
      srgbCapableFramebuffer*, floating*, maximized*, autoIconify*,
      doubleBuffer*, openglVersion*, makeContextCurrent*: bool
    bits*: tuple[r, g, b, a, stencil, depth: Option[int32]]
    accumBufferBits*: tuple[r, g, b, a: Option[int32]]
    nAuxBuffers*, nMultiSamples*: int32
    refreshRate*: Option[int32]
    contextReleaseBehavior*: ContextReleaseBehavior
    contextRobustness*: ContextRobustness
    contextCreationApi*: ContextCreationApi
    version*: OpenglEsVersion
    contextNoError*: bool
  SomeOpenglWindowConfigType* = OpenglWindowConfig|OpenglEsWindowConfig

# XXX: Can this be a constant?
let DefaultOpenglWindowConfig* = OpenglWindowConfig(
  size: (w: 640, h: 480),
  title: "Nim-GLFW window",
  fullscreenMonitor: NoMonitor,
  shareResourcesWith: nil.Window,
  visible: true,
  focused: true,
  decorated: true,
  resizable: false,
  stereo: false,
  srgbCapableFramebuffer: false,
  bits: (some(8i32), some(8i32), some(8i32), some(8i32), some(8i32), some(24i32)),
  accumBufferBits: (some(0i32), some(0i32), some(0i32), some(0i32)),
  nAuxBuffers: 0,
  nMultiSamples: 0,
  refreshRate: some(0i32),
  contextRobustness: crNoRobustness,
  contextCreationApi: ccaNativeContextApi,
  contextReleaseBehavior: crbAnyReleaseBehavior,
  version: glv10,
  forwardCompat: false,
  debugContext: false,
  contextNoError: false,
  makeContextCurrent: true,
  doubleBuffer: true,
)

# XXX: Can this be a constant?
let DefaultOpenglEsWindowConfig* = OpenglEsWindowConfig(
  size: (w: 640i32, h: 480i32),
  title: "Nim-GLFW window",
  fullscreenMonitor: NoMonitor,
  shareResourcesWith: nil,
  visible: true,
  focused: true,
  decorated: true,
  resizable: false,
  stereo: false,
  srgbCapableFramebuffer: false,
  bits: (some(8i32), some(8i32), some(8i32), some(8i32), some(8i32), some(24i32)),
  accumBufferBits: (some(0i32), some(0i32), some(0i32), some(0i32)),
  nAuxBuffers: 0,
  nMultiSamples: 0,
  refreshRate: some(0i32),
  contextRobustness: crNoRobustness,
  contextCreationApi: ccaNativeContextApi,
  contextReleaseBehavior: crbAnyReleaseBehavior,
  version: glesv10,
  contextNoError: false,
  makeContextCurrent: true,
  doubleBuffer: true,
)

proc setHints(c: SomeOpenglWindowConfigType) =
  template h(name, val: untyped) = wrapper.windowHint(name, val.int32)

  for k, v in c.fieldPairs:
    when k == "resizable":
      h(wrapper.hResizable, v)
    elif k == "visible":
      h(wrapper.hVisible, v)
    elif k == "decorated":
      h(wrapper.hDecorated, v)
    elif k == "bits":
      template t(hint: Hint, field: untyped) =
        const E = "An explicitly requested bit depth must be >= 0"
        assert field.get(0) >= 0, E
        h(hint, field.get(wrapper.DontCare))

      t(wrapper.hRedBits, v.r)
      t(wrapper.hGreenBits, v.r)
      t(wrapper.hBlueBits, v.r)
      t(wrapper.hAlphaBits, v.r)
      t(wrapper.hDepthBits, v.r)
      t(wrapper.hStencilBits, v.r)
    elif k == "accumBufferBits":
      template t(hint: Hint, field: untyped) =
        const E = "An explicitly requested bit depth must be >= 0"
        assert field.get(0) >= 0, E
        h(hint, field.get(wrapper.DontCare))

      t(wrapper.hAccumRedBits, v.r)
      t(wrapper.hAccumGreenBits, v.g)
      t(wrapper.hAccumBlueBits, v.b)
      t(wrapper.hAccumAlphaBits, v.a)
    elif k == "nAuxBuffers":
      h(wrapper.hAuxBuffers, v)
    elif k == "stereo":
      h(wrapper.hStereo, v)
    elif k == "nMultiSamples":
      h(wrapper.hSamples, v)
    elif k == "srgbCapableFramebuffer":
      h(wrapper.hSrgbCapable, v)
    elif k == "refreshRate":
      assert v.get(0) >= 0,
        "An explicitly requested refresh rate must be >= 0"
      h(wrapper.hRefreshRate, v.get(DontCare))
    elif k == "version":
      h(wrapper.hContextVersionMajor, v.major)
      h(wrapper.hContextVersionMinor, v.minor)
      h(wrapper.hContextRevision, v.revision)
    elif k == "hOpenglForwardCompat":
      h(wrapper.hOpenglForwardCompat, v)
    elif k == "hOpenglDebugContext":
      h(wrapper.hOpenglDebugContext, v)
    elif k == "focused":
      h(wrapper.hFocused, v)
    elif k == "floating":
      h(wrapper.hFloating, v)
    elif k == "maximized":
      h(wrapper.hMaximized, v)
    elif k == "autoIconify":
      h(wrapper.hAutoIconify, v)
    elif k == "doubleBuffer":
      h(wrapper.hDoubleBuffer, v)
    elif k == "contextReleaseBehavior":
      h(wrapper.hContextReleaseBehavior, v)
    elif k == "profile":
      h(wrapper.hOpenglProfile, v)
    elif k == "contextRobustness":
      h(wrapper.hContextRobustness, v)
    elif k == "contextCreationApi":
      h(wrapper.hContextCreationApi, v)
    elif k == "forwardCompat":
      h(wrapper.hOpenglForwardCompat, v)
    elif k == "debugContext":
      h(wrapper.hOpenglDebugContext, v)
    elif k == "contextNoError":
      h(wrapper.hContextNoError, v)
    elif k in ["size", "title", "fullscreenMonitor", "shareResourcesWith",
        "makeContextCurrent"]:
      discard
    else:
      {.fatal: "unhandled field: " & k.}

  when c is OpenglWindowConfig:
    h(wrapper.hClientApi, wrapper.oaOpenglApi)
  elif c is OpenglEsWindowConfig:
    h(wrapper.hClientApi, wrapper.oaOpenglEsApi)
  else:
    {.fatal: "unhandled type".}

proc newWindow*(handle: WindowHandle): Window =
  Window(handle: handle)

proc destroy*(w: Window) =
  wrapper.destroyWindow(w)
  gWindowTable.del(w)

proc makeContextCurrent*(w: Window) =
  wrapper.makeContextCurrent(w)

proc currentContext*(): Window =
  newWindow wrapper.getCurrentContext()

# XXX: the template below breaks if 'c' is typed as 'SomeOpenglWindowConfigType'
proc newWindow*(c = DefaultOpenglWindowConfig): Window =
  new(result)

  setHints(c)

  let sharedMonitor = if c.shareResourcesWith.isNil: nil
                      else: c.shareResourcesWith.handle
  result.handle = wrapper.createWindow(c.size.w, c.size.h, c.title,
    c.fullscreenMonitor, sharedMonitor).failIf(nil)
  gWindowTable.add result.handle, result

  if c.makeContextCurrent:
    result.makeContextCurrent()

  template get(f: untyped): bool {.dirty.} =
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

  charCb = proc(handle: WindowHandle, codePoint: uint32) {.cdecl.} =
    if get(charCb):
      cb(win, codePoint.Rune)
  discard wrapper.setCharCallback(result, charCb)

  charModsCb = proc(
      handle: WindowHandle, codePoint: uint32, modKeys: int32) {.cdecl.} =
    if get(charModsCb):
      cb(win, codePoint.Rune, initModifierKeySet(modKeys))
  discard wrapper.setCharModsCallback(result, charModsCb)

  dropCb = proc(
      handle: WindowHandle, count: int32, paths: cstringArray) {.cdecl.} =
    if get(dropCb):
      cb(win, initPathDropInfo(paths, count))
  discard wrapper.setDropCallback(result, dropCb)

proc swapBuffers*(w: Window) =
  wrapper.swapBuffers(w)

proc version*: tuple[major, minor, rev: int32] =
  wrapper.getVersion(result[0].addr, result[1].addr, result[2].addr)

proc versionString*: cstring =
  wrapper.getVersionString()

proc swapInterval*(interval: Natural) =
  wrapper.swapInterval(interval.int32)

proc getTime*(): float64 =
  wrapper.getTime()

proc setTime*(time: float64) =
  wrapper.setTime(time)

proc timerValue*: uint64 =
  wrapper.getTimerValue()

proc timerFrequency*: uint64 =
  wrapper.getTimerFrequency()

proc `icon=`*(w: Window, images: openarray[wrapper.ImageObj]) =
  wrapper.setWindowIcon(w, images.len.int32, images[0].unsafeAddr)

proc keyName*(key: Key): cstring =
  wrapper.getKeyName(key.int32, 0)

proc keyName*(scanCode: int32): cstring =
  wrapper.getKeyName(keyUnknown.int32, scanCode)

proc setSizeLimits*(w: Window, minwidth, minheight, maxwidth, maxheight: int32) =
  wrapper.setWindowSizeLimits(w, minwidth, minheight, maxwidth, maxheight)

proc setAspectRatio*(w: Window, numer, denom: int32) =
  wrapper.setWindowAspectRatio(w, numer, denom)
