static:
  assert cshort.sizeof == int16.sizeof and cint.sizeof == int32.sizeof,
    "Not binary compatible with GLFW. Please report this."

when defined(glfwJustCdecl):
  {.pragma: glfwImport, cdecl.}

elif not defined(glfwStaticLib): # dynamic linking
  when defined(windows):
    const GlfwDll = "glfw3.dll"
  elif defined(macosx):
    const GlfwDll = "libglfw3.dylib"
  else:
    const GlfwDll = "libglfw.so.3"
  {.pragma: glfwImport, dynlib: GlfwDll.}

else: # static linking
  import std/os

  const BaseDir = currentSourcePath.parentDir()
  const SrcDir = BaseDir / "src"

  when defined(windows):
    import std/strformat

    {.passC: fmt"-D_GLFW_WIN32 -I {BaseDir}/deps/mingw", passL: "-lopengl32 -lgdi32",
      compile: SrcDir / "win32_init.c",
      compile: SrcDir / "win32_joystick.c",
      compile: SrcDir / "win32_module.c",
      compile: SrcDir / "win32_monitor.c",
      compile: SrcDir / "win32_thread.c",
      compile: SrcDir / "win32_time.c",
      compile: SrcDir / "win32_window.c",
      compile: SrcDir / "wgl_context.c",
      compile: SrcDir / "egl_context.c",
      compile: SrcDir / "osmesa_context.c".}

  elif defined(macosx):
    {.passC: "-D_GLFW_COCOA",
      passL: "-framework Cocoa -framework OpenGL -framework IOKit -framework CoreVideo",
      compile: SrcDir / "cocoa_init.m",
      compile: SrcDir / "cocoa_joystick.m",
      compile: SrcDir / "cocoa_monitor.m",
      compile: SrcDir / "cocoa_window.m",
      compile: SrcDir / "cocoa_time.c",
      compile: SrcDir / "posix_module.c",
      compile: SrcDir / "posix_thread.c",
      compile: SrcDir / "nsgl_context.m",
      compile: SrcDir / "egl_context.c",
      compile: SrcDir / "osmesa_context.c".}

  elif defined(linux):
    # TODO untested
    {.passL: "-pthread -lGL -lX11 -lXrandr -lXxf86vm -lXi -lXcursor -lm -lXinerama".}

    when defined(wayland):
      {.passC: "-D_GLFW_WAYLAND",
      compile: SrcDir / "wl_init.c",
      compile: SrcDir / "wl_monitor.c",
      compile: SrcDir / "wl_window.c",
      compile: SrcDir / "posix_module.c",
      compile: SrcDir / "posix_time.c",
      compile: SrcDir / "posix_thread.c",
      compile: SrcDir / "xkb_unicode.c",
      compile: SrcDir / "egl_context.c",
      compile: SrcDir / "osmesa_context.c".}

    else: # x11
      {.passC: "-D_GLFW_X11",
      compile: SrcDir / "x11_init.c",
      compile: SrcDir / "x11_monitor.c",
      compile: SrcDir / "x11_window.c",
      compile: SrcDir / "xkb_unicode.c",
      compile: SrcDir / "posix_module.c",
      compile: SrcDir / "posix_time.c",
      compile: SrcDir / "posix_thread.c",
      compile: SrcDir / "glx_context.c",
      compile: SrcDir / "egl_context.c",
      compile: SrcDir / "osmesa_context.c".}

    {.compile: SrcDir / "linux_joystick.c".}
    {.compile: SrcDir / "posix_poll.c".}

  else: # neither Windows, macOS, or Linux
    # If unsupported/unknown OS, use null system
    # TODO untested
    {.compile: SrcDir / "posix_time.c",
      compile: SrcDir / "posix_thread.c",
      compile: SrcDir / "osmesa_context.c".}

  # Common
  {.compile: SrcDir / "context.c",
    compile: SrcDir / "init.c",
    compile: SrcDir / "null_init.c",
    compile: SrcDir / "null_monitor.c",
    compile: SrcDir / "null_window.c",
    compile: SrcDir / "null_joystick.c",
    compile: SrcDir / "input.c",
    compile: SrcDir / "monitor.c",
    compile: SrcDir / "platform.c",
    compile: SrcDir / "vulkan.c",
    compile: SrcDir / "window.c".}

  {.pragma: glfwImport.}


type
  MouseButton* {.size: int32.sizeof.} = enum
    mb1 = (0, "left mouse button")
    mb2 = (1, "right mouse button")
    mb3 = (2, "middle mouse button")
    mb4 = (3, "mouse button 4")
    mb5 = (4, "mouse button 5")
    mb6 = (5, "mouse button 6")
    mb7 = (6, "mouse button 7")
    mb8 = (7, "mouse button 8")

const
  mbLeft*   = mb1
  mbRight*  = mb2
  mbMiddle* = mb3

type
  ModifierKey* {.size: int32.sizeof.} = enum
    mkShift    = (0x00000001, "shift")
    mkCtrl     = (0x00000002, "ctrl")
    mkAlt      = (0x00000004, "alt")
    mkSuper    = (0x00000008, "super")
    mkCapsLock = (0x00000010, "capslock")
    mkNumLock  = (0x00000020, "numlock")

type
  Key* {.size: int32.sizeof.} = enum
    keyUnknown      = (-1, "unknown")
    keySpace        = (32, "space")
    keyApostrophe   = (39, "apostrophe")
    keyComma        = (44, "comma")
    keyMinus        = (45, "minus")
    keyPeriod       = (46, "period")
    keySlash        = (47, "slash")
    key0            = (48, "0")
    key1            = (49, "1")
    key2            = (50, "2")
    key3            = (51, "3")
    key4            = (52, "4")
    key5            = (53, "5")
    key6            = (54, "6")
    key7            = (55, "7")
    key8            = (56, "8")
    key9            = (57, "9")
    keySemicolon    = (59, "semicolon")
    keyEqual        = (61, "equal")
    keyA            = (65, "a")
    keyB            = (66, "b")
    keyC            = (67, "c")
    keyD            = (68, "d")
    keyE            = (69, "e")
    keyF            = (70, "f")
    keyG            = (71, "g")
    keyH            = (72, "h")
    keyI            = (73, "i")
    keyJ            = (74, "j")
    keyK            = (75, "k")
    keyl            = (76, "L")
    keyM            = (77, "m")
    keyN            = (78, "n")
    keyO            = (79, "o")
    keyP            = (80, "p")
    keyQ            = (81, "q")
    keyR            = (82, "r")
    keyS            = (83, "s")
    keyT            = (84, "t")
    keyU            = (85, "u")
    keyV            = (86, "v")
    keyW            = (87, "w")
    keyX            = (88, "x")
    keyY            = (89, "y")
    keyZ            = (90, "z")
    keyLeftBracket  = (91, "left bracket")
    keyBackslash    = (92, "backslash")
    keyRightBracket = (93, "right bracket")
    keyGraveAccent  = (96, "grave accent")
    keyWorld1       = (161, "world1")
    keyWorld2       = (162, "world2")
    keyEscape       = (256, "escape")
    keyEnter        = (257, "enter")
    keyTab          = (258, "tab")
    keyBackspace    = (259, "backspace")
    keyInsert       = (260, "insert")
    keyDelete       = (261, "delete")
    keyRight        = (262, "right")
    keyLeft         = (263, "left")
    keyDown         = (264, "down")
    keyUp           = (265, "up")
    keyPageUp       = (266, "page up")
    keyPageDown     = (267, "page down")
    keyHome         = (268, "home")
    keyEnd          = (269, "end")
    keyCapsLock     = (280, "caps lock")
    keyScrollLock   = (281, "scroll lock")
    keyNumLock      = (282, "num lock")
    keyPrintScreen  = (283, "print screen")
    keyPause        = (284, "pause")
    keyF1           = (290, "f1")
    keyF2           = (291, "f2")
    keyF3           = (292, "f3")
    keyF4           = (293, "f4")
    keyF5           = (294, "f5")
    keyF6           = (295, "f6")
    keyF7           = (296, "f7")
    keyF8           = (297, "f8")
    keyF9           = (298, "f9")
    keyF10          = (299, "f10")
    keyF11          = (300, "f11")
    keyF12          = (301, "f12")
    keyF13          = (302, "f13")
    keyF14          = (303, "f14")
    keyF15          = (304, "f15")
    keyF16          = (305, "f16")
    keyF17          = (306, "f17")
    keyF18          = (307, "f18")
    keyF19          = (308, "f19")
    keyF20          = (309, "f20")
    keyF21          = (310, "f21")
    keyF22          = (311, "f22")
    keyF23          = (312, "f23")
    keyF24          = (313, "f24")
    keyF25          = (314, "f25")
    keyKp0          = (320, "kp0")
    keyKp1          = (321, "kp1")
    keyKp2          = (322, "kp2")
    keyKp3          = (323, "kp3")
    keyKp4          = (324, "kp4")
    keyKp5          = (325, "kp5")
    keyKp6          = (326, "kp6")
    keyKp7          = (327, "kp7")
    keyKp8          = (328, "kp8")
    keyKp9          = (329, "kp9")
    keyKpDecimal    = (330, "kp decimal")
    keyKpDivide     = (331, "kp divide")
    keyKpMultiply   = (332, "kp multiply")
    keyKpSubtract   = (333, "kp subtract")
    keyKpAdd        = (334, "kp add")
    keyKpEnter      = (335, "kp enter")
    keyKpEqual      = (336, "kp equal")
    keyLeftShift    = (340, "left shift")
    keyLeftControl  = (341, "left control")
    keyLeftAlt      = (342, "left alt")
    keyLeftSuper    = (343, "left super")
    keyRightShift   = (344, "right shift")
    keyRightControl = (345, "right control")
    keyRightAlt     = (346, "right alt")
    keyRightSuper   = (347, "right super")
    keyMenu         = (348, "menu")

  KeyAction* {.size: int32.sizeof.} = enum
    kaUp     = (0, "up")
    kaDown   = (1, "down")
    kaRepeat = (2, "repeat")

type
  GamepadButton* {.size: int32.sizeof.} = enum
    gbA           = (0, "A")
    gbB           = (1, "B")
    gbX           = (2, "X")
    gbY           = (3, "Y")
    gbLeftBumper  = (4, "left bumper")
    gbRightBumper = (5, "right bumper")
    gbBack        = (6, "back")
    gbStart       = (7, "start")
    gbGuide       = (8, "guide")
    gbLeftThumb   = (9, "left thumb")
    gbRightThumb  = (10, "right thumb")
    gbDpadUp      = (11, "dpad up")
    gbDpadRight   = (12, "dpad right")
    gbDpadDown    = (13, "dpad down")
    gbDpadLeft    = (14, "dpad left")

const
  gbCross*    = gbA
  gbCircle*   = gbB
  gbSquare*   = gbX
  gbTriangle* = gbY

type
  GamepadAxis* {.size: int32.sizeof.} = enum
    gaLeftX        = (0, "left x")
    gaLeftY        = (1, "lefy y")
    gaRightX       = (2, "right x")
    gaRightY       = (3, "right y")
    gaLeftTrigger  = (4, "left trigger")
    gaRightTrigger = (5, "right trigger")

type
  Joystick* {.size: int32.sizeof} = enum
    joystick1  = (0, "joystick 0")
    joystick2  = (1, "joystick 1")
    joystick3  = (2, "joystick 2")
    joystick4  = (3, "joystick 3")
    joystick5  = (4, "joystick 4")
    joystick6  = (5, "joystick 5")
    joystick7  = (6, "joystick 6")
    joystick8  = (7, "joystick 6")
    joystick9  = (8, "joystick 7")
    joystick10 = (9, "joystick 9")
    joystick11 = (10, "joystick 10")
    joystick12 = (11, "joystick 11")
    joystick13 = (12, "joystick 12")
    joystick14 = (13, "joystick 13")
    joystick15 = (14, "joystick 14")
    joystick16 = (15, "joystick 15")

  JoystickHat* {.size: int32.sizeof} = enum
    # jhEnum or jhEnum = bitwise or between the values
    # FIXME: Find more idiomatic way to do or in enum
    jhCentered  = (0, "centered")
    jhUp        = (1, "up")
    jhRight     = (2, "right")
    jhRightUp   = (3, "right up")    # jhRight or jhUp
    jhDown      = (4, "down")
    jhRightDown = (6, "right down")  # jhRight or jhDown
    jhLeft      = (8, "left")
    jhLeftUp    = (9, "left up")     # jhLeft or jhUp
    jhLeftDown  = (12, "left down")  # jhLeft or jhDown

const
  buttonLast*   = gbDpadLeft
  joystickLast* = joystick16


type
  GamepadState* = object
    buttons: array[15, uint8]
    axes:    array[6, cfloat]

const
  Iconified* = 0x00020002

type
  Hint* {.size: int32.sizeof.} = enum
    hFocused                = 0x00020001
    hIconified              = 0x00020002
    hResizable              = 0x00020003
    hVisible                = 0x00020004
    hDecorated              = 0x00020005
    hAutoIconify            = 0x00020006
    hFloating               = 0x00020007
    hMaximized              = 0x00020008
    hCenterCursor           = 0x00020009
    hTransparentFramebuffer = 0x0002000A
    hHovered                = 0x0002000B
    hFocusOnShow            = 0x0002000C
    hMousePassthrough       = 0x0002000D
    hPositionX              = 0x0002000E
    hPositionY              = 0x0002000F
    hHideFromTaskbar        = 0x00020010
    hRedBits                = 0x00021001
    hGreenBits              = 0x00021002
    hBlueBits               = 0x00021003
    hAlphaBits              = 0x00021004
    hDepthBits              = 0x00021005
    hStencilBits            = 0x00021006
    hAccumRedBits           = 0x00021007
    hAccumGreenBits         = 0x00021008
    hAccumBlueBits          = 0x00021009
    hAccumAlphaBits         = 0x0002100A
    hAuxBuffers             = 0x0002100B
    hStereo                 = 0x0002100C
    hSamples                = 0x0002100D
    hSrgbCapable            = 0x0002100E
    hRefreshRate            = 0x0002100F
    hDoublebuffer           = 0x00021010
    hClientApi              = 0x00022001
    hContextVersionMajor    = 0x00022002
    hContextVersionMinor    = 0x00022003
    hContextRevision        = 0x00022004
    hContextRobustness      = 0x00022005
    hOpenglForwardCompat    = 0x00022006
    hOpenglDebugContext     = 0x00022007
    hOpenglProfile          = 0x00022008
    hContextReleaseBehavior = 0x00022009
    hContextNoError         = 0x0002200A
    hContextCreationApi     = 0x0002200B
    hScaleToMonitor         = 0x0002200C
    hScaleFramebuffer       = 0x0002200D
    hCocoaRetinaFrameBuffer = 0x00023001
    hCocoaFrameName         = 0x00023002
    hCocoaGraphicsSwitching = 0x00023003
    hX11ClassName           = 0x00024001
    hX11InstanceName        = 0x00024002
    hWin32KeyboardMenu      = 0x00025001
    hWin32ShowDefault       = 0x00025002
    hWaylandAppId           = 0x00026001

  InitHint* {.size: int32.sizeof.} = enum
    ihJoystickHatButtons  = 0x00050001
    ihAnglePlatformType   = 0x00050002
    ihPlatform            = 0x00050003
    ihCocoaCHDir          = 0x00051001
    ihCocoaMenuBar        = 0x00051002
    ihX11XcbVulkanSurface = 0x00052001
    ihWaylandLibdecor     = 0x00053001

  PlatformHint* {.size: int32.sizeof.} = enum
    phAny     = 0x00060000
    phWin32   = 0x00060001
    phCocoA   = 0x00060002
    phWayland = 0x00060003
    phX11     = 0x00060004
    phNulL    = 0x00060005

  ContextReleaseBehavior* {.size: int32.sizeof.} = enum
    crbAnyReleaseBehavior   = 0
    crbReleaseBehaviorFlush = 0x00035001
    crbReleaseBehaviorNone  = 0x00035002

  ClientApi* {.size: int32.sizeof.} = enum
    oaNoApi       = 0
    oaOpenglApi   = 0x00030001
    oaOpenglEsApi = 0x00030002

  ContextCreationApi* {.size: int32.sizeof.} = enum
    ccaNativeContextApi = 0x00036001
    ccaEglContextApi    = 0x00036002
    ccaOSMesaContextApi = 0x00036003

  ContextRobustness* {.size: int32.sizeof.} = enum
    crNoRobustness        = 0
    crNoResetNotification = 0x00031001
    crLoseContextOnReset  = 0x00031002

  OpenglProfile* {.size: int32.sizeof.} = enum
    opAnyProfile    = 0
    opCoreProfile   = 0x00032001
    opCompatProfile = 0x00032002

  MonitorConnection* {.size: int32.sizeof.} = enum
    mcConnected    = 0x00040001
    mcDisconnected = 0x00040002

  AnglePlatformType* {.size: int32.sizeof.} = enum
    aptNone     = 0x00037001
    aptOpengl   = 0x00037002
    aptOpengles = 0x00037003
    aptD3d9     = 0x00037004
    aptD3d11    = 0x00037005
    aptVulkan   = 0x00037007
    aptMetal    = 0x00037008

  WaylandHint* {.size: int32.sizeof.} = enum
    whPreferLibdecor  = 0x00038001
    whDisableLibdecor = 0x00038002

converter toBool*(m: MonitorConnection): bool =
  case m
  of mcConnected:
    true
  of mcDisconnected:
    false

type
  CursorMode* {.size: int32.sizeof.} = enum
    cmNormal   = 0x00034001
    cmHidden   = 0x00034002
    cmDisabled = 0x00034003
    cmCaptured = 0x00034004

const
  CursorModeConst*    = 0x00033001'i32 # XXX
  StickyKeys*         = 0x00033002'i32
  StickyMouseButtons* = 0x00033003'i32
  LockKeyMods*        = 0x00033004'i32
  RawMouseMotion*     = 0x00033005'i32
  AnyPosition*        = 0x80000000'i32
  DontCare*           = -1

type
  CursorShape* {.size: int32.sizeof.} = enum
    csArrow       = 0x00036001
    csIBeam       = 0x00036002
    csCrosshair   = 0x00036003
    csHand        = 0x00036004
    csResizeEW    = 0x00036005
    csResizeNS    = 0x00036006
    csResizeNWSE  = 0x00036007
    csResizeNESW  = 0x00036008
    csResizeAll   = 0x00036009
    csNotAllowed  = 0x0003600a

type
  Window*  = ptr object
  Monitor* = ptr object
  Cursor*  = ptr object

  VideoModeObj* {.bycopy.} = object
    width*:       int32
    height*:      int32
    redBits*:     int32
    greenBits*:   int32
    blueBits*:    int32
    refreshRate*: int32

  VideoMode* = ptr VideoModeObj

  GammaRamp* {.bycopy.} = ptr object
    red*:   ptr uint16
    green*: ptr uint16
    blue*:  ptr uint16
    size*:  cuint

  IconImageObj* {.bycopy.} = object
    width*:  int32
    height*: int32
    pixels*: ptr uint8

  IconImage* = ptr IconImageObj

type
  OpenGlProc*            = proc () {.cdecl.}
  Vkproc*                = proc () {.cdecl.}
  Errorfun*              = proc (a2: int32; a3: cstring) {.cdecl.}
  Windowposfun*          = proc (a2: Window; a3: int32; a4: int32) {.cdecl.}
  Windowsizefun*         = proc (a2: Window; a3: int32; a4: int32) {.cdecl.}
  Windowclosefun*        = proc (a2: Window) {.cdecl.}
  Windowrefreshfun*      = proc (a2: Window) {.cdecl.}
  Windowfocusfun*        = proc (a2: Window; a3: int32) {.cdecl.}
  Windowmaximizefun*     = proc (a2: Window, a3: int32) {.cdecl.}
  Windowiconifyfun*      = proc (a2: Window; a3: int32) {.cdecl.}
  Framebuffersizefun*    = proc (a2: Window; a3: int32; a4: int32) {.cdecl.}
  Windowcontentscalefun* = proc (a2: Window, a3, a4: cfloat)

  Cursorposfun*   = proc (a2: Window; a3: cdouble; a4: cdouble) {.cdecl.}
  Cursorenterfun* = proc (a2: Window; a3: int32) {.cdecl.}
  Scrollfun*      = proc (a2: Window; a3: cdouble; a4: cdouble) {.cdecl.}
  Charfun*        = proc (a2: Window; a3: cuint) {.cdecl.}
  Charmodsfun*    = proc (a2: Window; a3: cuint; a4: int32) {.cdecl.}
  Dropfun*        = proc (a2: Window; a3: int32; a4: cstringArray) {.cdecl.}
  Monitorfun*     = proc (a2: Monitor; a3: int32) {.cdecl.}
  Joystickfun*    = proc (a2: int32; a3: int32) {.cdecl.}

  Mousebuttonfun* = proc (a2: Window; a3: int32; a4: int32;
                          a5: int32) {.cdecl.}

  Keyfun*  = proc (a2: Window; a3: int32; a4: int32; a5: int32;
                   a6: int32) {.cdecl.}

import std/macros
from std/strutils import toUpperAscii

proc renameProcs(n: NimNode) {.compileTime.} =
  template pragmas(n: string) = {.glfwImport, cdecl, importc: n.}
  for s in n:
    case s.kind
    of nnkProcDef:
      let oldName = $s.name
      let newName = "glfw" & (oldName[0]).toUpperAscii & oldName[1..^1]
      s.pragma = getAst(pragmas(newName))
    else:
      renameProcs(s)

macro generateProcs() =
  template getProcs {.dirty.} =

    # ------------------------------------------------------------------------
    # Initialisation
    # ------------------------------------------------------------------------
    proc init*(): int32
    proc initHint*(hint, value: int32)
    # TODO void glfwInitAllocator(const GLFWallocator* allocator);
    # TODO void glfwInitVulkanLoader(PFN_vkGetInstanceProcAddr loader);
    #
    proc terminate*()

    proc getVersion*(major: ptr int32; minor: ptr int32; rev: ptr int32)
    proc getVersionString*(): cstring

    proc getError*(description: cstringArray): int32
    proc setErrorCallback*(cbfun: Errorfun): Errorfun

    # TODO int glfwGetPlatform(void);
    # TODO int glfwPlatformSupported(int platform);

    # ------------------------------------------------------------------------
    # Monitor handling
    # ------------------------------------------------------------------------
    proc getMonitors*(count: ptr int32): Monitor
    proc getPrimaryMonitor*(): Monitor
    proc getMonitorPos*(monitor: Monitor; xpos: ptr int32; ypos: ptr int32)

    proc getMonitorWorkarea*(monitor: Monitor, xpos, ypos, width,
                             height: ptr int32)

    proc getMonitorPhysicalSize*(monitor: Monitor; widthMM: ptr int32;
                                 heightMM: ptr int32)

    proc getMonitorContentScale*(monitor: Monitor, xscale, yscale: ptr cfloat)
    proc getMonitorName*(monitor: Monitor): cstring
    proc setMonitorUserPointer*(monitor: Monitor, pointerr: pointer)
    proc getMonitorUserPointer*(monitor: Monitor): pointer
    proc setMonitorCallback*(cbfun: Monitorfun): Monitorfun

    proc getVideoModes*(monitor: Monitor; count: ptr int32): VideoMode
    proc getVideoMode*(monitor: Monitor): VideoMode

    proc setGamma*(monitor: Monitor; gamma: cfloat)
    proc getGammaRamp*(monitor: Monitor): Gammaramp
    proc setGammaRamp*(monitor: Monitor; ramp: Gammaramp)

    # ------------------------------------------------------------------------
    # Window handling
    # ------------------------------------------------------------------------
    proc defaultWindowHints*()
    proc windowHint*(hint: int32; value: int32)
    proc windowHintString*(hint: int32, value: cstring)

    proc createWindow*(width: int32; height: int32; title: cstring;
                       monitor: Monitor; share: Window): Window

    proc destroyWindow*(window: Window)
    proc windowShouldClose*(window: Window): int32
    proc setWindowShouldClose*(window: Window; value: int32)

    proc getWindowTitle*(window: Window): cstring
    proc setWindowTitle*(window: Window; title: cstring)
    proc setWindowIcon*(window: Window; count: int32; images: IconImage)
    proc getWindowPos*(window: Window; xpos: ptr int32; ypos: ptr int32)
    proc setWindowPos*(window: Window; xpos: int32; ypos: int32)
    proc getWindowSize*(window: Window; width: ptr int32; height: ptr int32)

    proc setWindowSizeLimits*(window: Window; minwidth: int32;
                              minheight: int32; maxwidth: int32;
                              maxheight: int32)

    proc setWindowAspectRatio*(window: Window; numer: int32; denom: int32)
    proc setWindowSize*(window: Window; width: int32; height: int32)

    proc getFramebufferSize*(window: Window; width: ptr int32;
                             height: ptr int32)

    proc getWindowFrameSize*(window: Window; left: ptr int32; top: ptr int32;
                             right: ptr int32; bottom: ptr int32)

    proc getWindowContentScale*(window: Window, xscale, yscale: ptr cfloat)

    proc getWindowOpacity*(window: Window): cfloat
    proc setWindowOpacity*(window: Window, opacity: cfloat)

    proc iconifyWindow*(window: Window)
    proc restoreWindow*(window: Window)
    proc maximizeWindow*(window: Window)
    proc showWindow*(window: Window)
    proc hideWindow*(window: Window)
    proc focusWindow*(window: Window)
    proc requestWindowAttention*(window: Window)

    proc getWindowMonitor*(window: Window): Monitor

    proc setWindowMonitor*(window: Window; monitor: Monitor;
                           xpos: int32; ypos: int32;
                           width: int32; height: int32;
                           refreshRate: int32)

    proc getWindowAttrib*(window: Window; attrib: int32): int32
    proc setWindowAttrib*(window: Window, attrib, value: int32)
    proc setWindowUserPointer*(window: Window; pointer: pointer)
    proc getWindowUserPointer*(window: Window): pointer

    # Window callbacks
    proc setWindowPosCallback*(window: Window;
                               cbfun: Windowposfun): Windowposfun

    proc setWindowSizeCallback*(window: Window;
                                cbfun: Windowsizefun): Windowsizefun

    proc setWindowCloseCallback*(window: Window;
                                 cbfun: Windowclosefun): Windowclosefun

    proc setWindowRefreshCallback*(window: Window;
                                   cbfun: Windowrefreshfun): Windowrefreshfun

    proc setWindowFocusCallback*(window: Window;
                                 cbfun: Windowfocusfun): Windowfocusfun

    proc setWindowIconifyCallback*(window: Window;
      cbfun: Windowiconifyfun): Windowiconifyfun

    proc setWindowMaximizeCallback*(window: Window;
      cbfun: Windowmaximizefun): Windowmaximizefun

    proc setFramebufferSizeCallback*(window: Window;
      cbfun: Framebuffersizefun): Framebuffersizefun

    proc setWindowContentScaleCallback*(window: Window,
      cbfun: Windowcontentscalefun): Windowcontentscalefun

    # ------------------------------------------------------------------------
    # Event handling
    # ------------------------------------------------------------------------
    proc pollEvents*()
    proc waitEvents*()
    proc waitEventsTimeout*(timeout: cdouble)
    proc postEmptyEvent*()

    # ------------------------------------------------------------------------
    # Input handling
    # ------------------------------------------------------------------------
    proc getInputMode*(window: Window; mode: int32): int32
    proc setInputMode*(window: Window; mode: int32; value: int32)

    proc rawMouseMotionSupported*(): int32

    proc getKeyName*(key: int32; scancode: int32): cstring
    proc getKeyScancode*(key: int32): int32
    proc getKey*(window: Window; key: int32): int32

    proc getMouseButton*(window: Window; button: int32): int32

    proc getCursorPos*(window: Window; xpos: ptr cdouble; ypos: ptr cdouble)
    proc setCursorPos*(window: Window; xpos: cdouble; ypos: cdouble)
    proc createCursor*(image: IconImage; xhot: int32; yhot: int32): Cursor
    proc createStandardCursor*(shape: CursorShape): Cursor
    proc destroyCursor*(cursor: Cursor)
    proc setCursor*(window: Window; cursor: Cursor)

    # Keyboard & mouse callbacks
    proc setKeyCallback*(window: Window; cbfun: Keyfun): Keyfun
    proc setCharCallback*(window: Window; cbfun: Charfun): Charfun
    proc setCharModsCallback*(window: Window; cbfun: Charmodsfun): Charmodsfun

    proc setMouseButtonCallback*(window: Window;
                                 cbfun: Mousebuttonfun): Mousebuttonfun

    proc setCursorPosCallback*(window: Window;
                               cbfun: Cursorposfun): Cursorposfun

    proc setCursorEnterCallback*(window: Window;
                                 cbfun: Cursorenterfun): Cursorenterfun

    proc setScrollCallback*(window: Window; cbfun: Scrollfun): Scrollfun

    proc setDropCallback*(window: Window; cbfun: Dropfun): Dropfun

    # Joystick functions
    proc joystickPresent*(joy: int32): int32
    proc getJoystickAxes*(joy: int32; count: ptr int32): ptr cfloat
    proc getJoystickButtons*(joy: int32; count: ptr int32): ptr uint8
    proc getJoystickHats*(jid: int32, count: ptr int32): ptr uint8
    proc getJoystickName*(joy: int32): cstring
    proc getJoystickGUID*(jid: int32): cstring
    proc setJoystickUserPointer*(jid: int, pointerr: pointer)
    proc getJoystickUserPointer*(jid: int32): pointer
    proc setJoystickCallback*(cbfun: Joystickfun): Joystickfun

    proc joystickIsGamepad*(jid: int32): int32
    proc updateGamepadMappings*(str: cstring): int32
    proc getGamepadName*(jid: int32): cstring
    proc getGamepadState*(jid: int32, state: ptr GamepadState): int32

    # Clipboard functions
    proc setClipboardString*(window: Window; string: cstring)
    proc getClipboardString*(window: Window): cstring

    # ------------------------------------------------------------------------
    # Timer functions
    # ------------------------------------------------------------------------
    proc getTime*(): cdouble
    proc setTime*(time: cdouble)
    proc getTimerValue*(): uint64
    proc getTimerFrequency*(): uint64

    # ------------------------------------------------------------------------
    # Context & OS integration functions
    # ------------------------------------------------------------------------
    proc makeContextCurrent*(window: Window)
    proc getCurrentContext*(): Window

    proc swapBuffers*(window: Window)
    proc swapInterval*(interval: int32)

    proc extensionSupported*(extension: cstring): int32
    proc getProcAddress*(procname: cstring): OpenGlProc
    proc vulkanSupported*(): int32
    proc getRequiredInstanceExtensions*(count: ptr uint32): cstringArray

    when defined(VK_VERSION_1_0):
      proc getInstanceProcAddress*(instance: VkInstance;
                                   procname: cstring): Vkproc

      proc getPhysicalDevicePresentationSupport*(instance: VkInstance;
        device: VkPhysicalDevice; queuefamily: uint32): int32

      proc createWindowSurface*(instance: VkInstance; window: Window;
        allocator: ptr VkAllocationCallbacks;
        surface: ptr VkSurfaceKHR): VkResult

    # ------------------------------------------------------------------------
    # Extra nim-glfw helper functions
    # ------------------------------------------------------------------------
    when defined(macosx):
      proc getCocoaOpenedFilenames*(): cstringArray
      proc freeCocoaOpenedFilenames*()


  result = getAst(getProcs())
  renameProcs(result)

generateProcs()
