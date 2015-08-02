when defined(glfwDynlib):
  when defined(windows):
    const glfwDll = "glfw3.dll"
  elif defined(macosx):
    const glfwDll = "libglfw3.dylib"
  else:
    const glfwDll = "libglfw.so.3"
  {.pragma: glfwImport, dynlib: glfwDll.}
  {.deadCodeElim: on.}

else:
  when defined(arm) or defined(wayland) or defined(mir) or defined(gles):
    {.passC: "-D_GLFW_USE_GLESV2".}
  else:
    {.passC: "-D_GLFW_USE_OPENGL".}

  when defined(windows):
    {.passC: "-D_GLFW_WIN32 -D_GLFW_WGL", passL: "-lopengl32 -lgdi32",
      compile: "glfw/src/win32_init.c", compile: "glfw/src/win32_monitor.c",
      compile: "glfw/src/win32_time.c", compile: "glfw/src/win32_tls.c",
      compile: "glfw/src/win32_window.c", compile: "glfw/src/winmm_joystick.c",
      compile: "glfw/src/wgl_context.c".}
  elif defined(macosx):
    {.passC: "-D_GLFW_COCOA -D_GLFW_NSGL -D_GLFW_USE_CHDIR -D_GLFW_USE_MENUBAR -D_GLFW_USE_RETINA",
      passL: "-framework Cocoa -framework OpenGL -framework IOKit -framework CoreVideo",
      compile: "glfw/src/mach_time.c", compile: "glfw/src/posix_tls.c",
      compile: "glfw/src/cocoa_init.m", compile: "glfw/src/cocoa_monitor.m",
      compile: "glfw/src/cocoa_window.m", compile: "glfw/src/iokit_joystick.m",
      compile: "glfw/src/nsgl_context.m".}
  else:
    {.passC: "-D_GLFW_HAS_DLOPEN",
      passL: "-pthread -lGL -lX11 -lXrandr -lXxf86vm -lXi -lXcursor -lm -lXinerama".}

    when defined(wayland):
      {.passC: "-D_GLFW_WAYLAND -D_GLFW_EGL",
        compile: "glfw/src/egl_context.c", compile: "glfw/src/wl_init.c",
        compile: "glfw/src/wl_monitor.c", compile: "glfw/src/wl_window.c".}
    elif defined(mir):
      {.passC: "-D_GLFW_MIR -D_GLFW_EGL",
        compile: "glfw/src/egl_context.c", compile: "glfw/src/mir_init.c",
        compile: "glfw/src/mir_monitor.c", compile: "glfw/src/mir_window.c".}
    else:
      {.passC: "-D_GLFW_X11 -D_GLFW_GLX -D_GLFW_HAS_GLXGETPROCADDRESSARB",
        compile: "glfw/src/glx_context.c", compile: "glfw/src/x11_init.c",
        compile: "glfw/src/x11_monitor.c", compile: "glfw/src/x11_window.c".}

    {.compile: "glfw/src/xkb_unicode.c", compile: "glfw/src/linux_joystick.c",
      compile: "glfw/src/posix_time.c", compile: "glfw/src/posix_tls.c".}

  {.compile: "glfw/src/context.c", compile: "glfw/src/init.c",
    compile: "glfw/src/input.c", compile: "glfw/src/monitor.c",
    compile: "glfw/src/window.c".}

  {.pragma: glfwImport.}

const
  VERSION_MAJOR* = 3
  VERSION_MINOR* = 0
  VERSION_REVISION* = 4

const
  RELEASE* = 0
  PRESS* = 1
  REPEAT* = 2

const
  KEY_UNKNOWN* = - 1
  KEY_SPACE* = 32
  KEY_APOSTROPHE* = 39
  KEY_COMMA* = 44
  KEY_MINUS* = 45
  KEY_PERIOD* = 46
  KEY_SLASH* = 47
  KEY_0* = 48
  KEY_1* = 49
  KEY_2* = 50
  KEY_3* = 51
  KEY_4* = 52
  KEY_5* = 53
  KEY_6* = 54
  KEY_7* = 55
  KEY_8* = 56
  KEY_9* = 57
  KEY_SEMICOLON* = 59
  KEY_EQUAL* = 61
  KEY_A* = 65
  KEY_B* = 66
  KEY_C* = 67
  KEY_D* = 68
  KEY_E* = 69
  KEY_F* = 70
  KEY_G* = 71
  KEY_H* = 72
  KEY_I* = 73
  KEY_J* = 74
  KEY_K* = 75
  KEY_L* = 76
  KEY_M* = 77
  KEY_N* = 78
  KEY_O* = 79
  KEY_P* = 80
  KEY_Q* = 81
  KEY_R* = 82
  KEY_S* = 83
  KEY_T* = 84
  KEY_U* = 85
  KEY_V* = 86
  KEY_W* = 87
  KEY_X* = 88
  KEY_Y* = 89
  KEY_Z* = 90
  KEY_LEFT_BRACKET* = 91
  KEY_BACKSLASH* = 92
  KEY_RIGHT_BRACKET* = 93
  KEY_GRAVE_ACCENT* = 96
  KEY_WORLD_1* = 161
  KEY_WORLD_2* = 162
  KEY_ESCAPE* = 256
  KEY_ENTER* = 257
  KEY_TAB* = 258
  KEY_BACKSPACE* = 259
  KEY_INSERT* = 260
  KEY_DELETE* = 261
  KEY_RIGHT* = 262
  KEY_LEFT* = 263
  KEY_DOWN* = 264
  KEY_UP* = 265
  KEY_PAGE_UP* = 266
  KEY_PAGE_DOWN* = 267
  KEY_HOME* = 268
  KEY_END* = 269
  KEY_CAPS_LOCK* = 280
  KEY_SCROLL_LOCK* = 281
  KEY_NUM_LOCK* = 282
  KEY_PRINT_SCREEN* = 283
  KEY_PAUSE* = 284
  KEY_F1* = 290
  KEY_F2* = 291
  KEY_F3* = 292
  KEY_F4* = 293
  KEY_F5* = 294
  KEY_F6* = 295
  KEY_F7* = 296
  KEY_F8* = 297
  KEY_F9* = 298
  KEY_F10* = 299
  KEY_F11* = 300
  KEY_F12* = 301
  KEY_F13* = 302
  KEY_F14* = 303
  KEY_F15* = 304
  KEY_F16* = 305
  KEY_F17* = 306
  KEY_F18* = 307
  KEY_F19* = 308
  KEY_F20* = 309
  KEY_F21* = 310
  KEY_F22* = 311
  KEY_F23* = 312
  KEY_F24* = 313
  KEY_F25* = 314
  KEY_KP_0* = 320
  KEY_KP_1* = 321
  KEY_KP_2* = 322
  KEY_KP_3* = 323
  KEY_KP_4* = 324
  KEY_KP_5* = 325
  KEY_KP_6* = 326
  KEY_KP_7* = 327
  KEY_KP_8* = 328
  KEY_KP_9* = 329
  KEY_KP_DECIMAL* = 330
  KEY_KP_DIVIDE* = 331
  KEY_KP_MULTIPLY* = 332
  KEY_KP_SUBTRACT* = 333
  KEY_KP_ADD* = 334
  KEY_KP_ENTER* = 335
  KEY_KP_EQUAL* = 336
  KEY_LEFT_SHIFT* = 340
  KEY_LEFT_CONTROL* = 341
  KEY_LEFT_ALT* = 342
  KEY_LEFT_SUPER* = 343
  KEY_RIGHT_SHIFT* = 344
  KEY_RIGHT_CONTROL* = 345
  KEY_RIGHT_ALT* = 346
  KEY_RIGHT_SUPER* = 347
  KEY_MENU* = 348
  KEY_LAST* = KEY_MENU

const
  MOD_SHIFT* = 0x00000001
  MOD_CONTROL* = 0x00000002
  MOD_ALT* = 0x00000004
  MOD_SUPER* = 0x00000008

const
  MOUSE_BUTTON_1* = 0
  MOUSE_BUTTON_2* = 1
  MOUSE_BUTTON_3* = 2
  MOUSE_BUTTON_4* = 3
  MOUSE_BUTTON_5* = 4
  MOUSE_BUTTON_6* = 5
  MOUSE_BUTTON_7* = 6
  MOUSE_BUTTON_8* = 7
  MOUSE_BUTTON_LAST* = MOUSE_BUTTON_8
  MOUSE_BUTTON_LEFT* = MOUSE_BUTTON_1
  MOUSE_BUTTON_RIGHT* = MOUSE_BUTTON_2
  MOUSE_BUTTON_MIDDLE* = MOUSE_BUTTON_3

const
  JOYSTICK_1* = 0
  JOYSTICK_2* = 1
  JOYSTICK_3* = 2
  JOYSTICK_4* = 3
  JOYSTICK_5* = 4
  JOYSTICK_6* = 5
  JOYSTICK_7* = 6
  JOYSTICK_8* = 7
  JOYSTICK_9* = 8
  JOYSTICK_10* = 9
  JOYSTICK_11* = 10
  JOYSTICK_12* = 11
  JOYSTICK_13* = 12
  JOYSTICK_14* = 13
  JOYSTICK_15* = 14
  JOYSTICK_16* = 15
  JOYSTICK_LAST* = JOYSTICK_16

const
  NOT_INITIALIZED* = 0x00010001
  NO_CURRENT_CONTEXT* = 0x00010002
  INVALID_ENUM* = 0x00010003
  INVALID_VALUE* = 0x00010004
  OUT_OF_MEMORY* = 0x00010005
  API_UNAVAILABLE* = 0x00010006
  VERSION_UNAVAILABLE* = 0x00010007
  PLATFORM_ERROR* = 0x00010008
  FORMAT_UNAVAILABLE* = 0x00010009

const
  FOCUSED* = 0x00020001
  ICONIFIED* = 0x00020002
  RESIZABLE* = 0x00020003
  VISIBLE* = 0x00020004
  DECORATED* = 0x00020005
  RED_BITS* = 0x00021001
  GREEN_BITS* = 0x00021002
  BLUE_BITS* = 0x00021003
  ALPHA_BITS* = 0x00021004
  DEPTH_BITS* = 0x00021005
  STENCIL_BITS* = 0x00021006
  ACCUM_RED_BITS* = 0x00021007
  ACCUM_GREEN_BITS* = 0x00021008
  ACCUM_BLUE_BITS* = 0x00021009
  ACCUM_ALPHA_BITS* = 0x0002100A
  AUX_BUFFERS* = 0x0002100B
  STEREO* = 0x0002100C
  SAMPLES* = 0x0002100D
  SRGB_CAPABLE* = 0x0002100E
  REFRESH_RATE* = 0x0002100F
  CLIENT_API* = 0x00022001
  CONTEXT_VERSION_MAJOR* = 0x00022002
  CONTEXT_VERSION_MINOR* = 0x00022003
  CONTEXT_REVISION* = 0x00022004
  CONTEXT_ROBUSTNESS* = 0x00022005
  OPENGL_FORWARD_COMPAT* = 0x00022006
  OPENGL_DEBUG_CONTEXT* = 0x00022007
  OPENGL_PROFILE* = 0x00022008
  OPENGL_API* = 0x00030001
  OPENGL_ES_API* = 0x00030002
  NO_ROBUSTNESS* = 0
  NO_RESET_NOTIFICATION* = 0x00031001
  LOSE_CONTEXT_ON_RESET* = 0x00031002
  OPENGL_ANY_PROFILE* = 0
  OPENGL_CORE_PROFILE* = 0x00032001
  OPENGL_COMPAT_PROFILE* = 0x00032002
  CURSOR* = 0x00033001
  STICKY_KEYS* = 0x00033002
  STICKY_MOUSE_BUTTONS* = 0x00033003
  CURSOR_NORMAL* = 0x00034001
  CURSOR_HIDDEN* = 0x00034002
  CURSOR_DISABLED* = 0x00034003
  CONNECTED* = 0x00040001
  DISCONNECTED* = 0x00040002

type
  GLFWwindow* = pointer
  GLFWmonitor* = pointer

type
  GLFWglproc* = proc () {.cdecl.}
  GLFWerrorfun* = proc (a2: cint; a3: cstring) {.cdecl.}
  GLFWwindowposfun* = proc (a2: GLFWwindow; a3: cint; a4: cint) {.cdecl.}
  GLFWwindowsizefun* = proc (a2: GLFWwindow; a3: cint; a4: cint) {.cdecl.}
  GLFWwindowclosefun* = proc (a2: GLFWwindow) {.cdecl.}
  GLFWwindowrefreshfun* = proc (a2: GLFWwindow) {.cdecl.}
  GLFWwindowfocusfun* = proc (a2: GLFWwindow; a3: cint) {.cdecl.}
  GLFWwindowiconifyfun* = proc (a2: GLFWwindow; a3: cint) {.cdecl.}
  GLFWframebuffersizefun* = proc (a2: GLFWwindow; a3: cint; a4: cint) {.
      cdecl.}
  GLFWmousebuttonfun* = proc (a2: GLFWwindow; a3: cint; a4: cint; a5: cint) {.
      cdecl.}
  GLFWcursorposfun* = proc (a2: GLFWwindow; a3: cdouble; a4: cdouble) {.
      cdecl.}
  GLFWcursorenterfun* = proc (a2: GLFWwindow; a3: cint) {.cdecl.}
  GLFWscrollfun* = proc (a2: GLFWwindow; a3: cdouble; a4: cdouble) {.cdecl.}
  GLFWkeyfun* = proc (a2: GLFWwindow; a3: cint; a4: cint; a5: cint;
                      a6: cint) {.cdecl.}
  GLFWcharfun* = proc (a2: GLFWwindow; a3: cuint) {.cdecl.}
  GLFWmonitorfun* = proc (a2: GLFWmonitor; a3: cint) {.cdecl.}

type
  GLFWvidmode* {.pure, final.} = object
    width*, height*, redBits*, greenBits*, blueBits*, refreshRate*: cint

type
  GLFWgammaramp* {.pure, final.} = object
    red, green, blue*: ptr cushort
    size*: cuint

proc init*(): cint {.cdecl, importc: "glfwInit", glfwImport.}
proc terminate*() {.cdecl, importc: "glfwTerminate", glfwImport.}
proc getVersion*(major: ptr cint; minor: ptr cint; rev: ptr cint) {.cdecl,
    importc: "glfwGetVersion", glfwImport.}
proc getVersionString*(): cstring {.cdecl, importc: "glfwGetVersionString",
                                    glfwImport.}
proc setErrorCallback*(cbfun: GLFWerrorfun): GLFWerrorfun {.cdecl,
    importc: "glfwSetErrorCallback", glfwImport.}
proc getMonitors*(count: ptr cint): ptr GLFWmonitor {.cdecl,
    importc: "glfwGetMonitors", glfwImport.}
proc getPrimaryMonitor*(): GLFWmonitor {.cdecl,
    importc: "glfwGetPrimaryMonitor", glfwImport.}
proc getMonitorPos*(monitor: GLFWmonitor; xpos: ptr cint; ypos: ptr cint) {.
    cdecl, importc: "glfwGetMonitorPos", glfwImport.}
proc getMonitorPhysicalSize*(monitor: GLFWmonitor; width: ptr cint;
                             height: ptr cint) {.cdecl,
    importc: "glfwGetMonitorPhysicalSize", glfwImport.}
proc getMonitorName*(monitor: GLFWmonitor): cstring {.cdecl,
    importc: "glfwGetMonitorName", glfwImport.}
proc setMonitorCallback*(cbfun: GLFWmonitorfun): GLFWmonitorfun {.cdecl,
    importc: "glfwSetMonitorCallback", glfwImport.}
proc getVideoModes*(monitor: GLFWmonitor; count: ptr cint): ptr GLFWvidmode {.
    cdecl, importc: "glfwGetVideoModes", glfwImport.}
proc getVideoMode*(monitor: GLFWmonitor): ptr GLFWvidmode {.cdecl,
    importc: "glfwGetVideoMode", glfwImport.}
proc setGamma*(monitor: GLFWmonitor; gamma: cfloat) {.cdecl,
    importc: "glfwSetGamma", glfwImport.}
proc getGammaRamp*(monitor: GLFWmonitor): ptr GLFWgammaramp {.cdecl,
    importc: "glfwGetGammaRamp", glfwImport.}
proc setGammaRamp*(monitor: GLFWmonitor; ramp: ptr GLFWgammaramp) {.cdecl,
    importc: "glfwSetGammaRamp", glfwImport.}
proc defaultWindowHints*() {.cdecl, importc: "glfwDefaultWindowHints",
                             glfwImport.}
proc windowHint*(target: cint; hint: cint) {.cdecl, importc: "glfwWindowHint",
    glfwImport.}
proc createWindow*(width: cint; height: cint; title: cstring;
                   monitor: GLFWmonitor; share: GLFWwindow): GLFWwindow {.
    cdecl, importc: "glfwCreateWindow", glfwImport.}
proc destroyWindow*(window: GLFWwindow) {.cdecl,
    importc: "glfwDestroyWindow", glfwImport.}
proc windowShouldClose*(window: GLFWwindow): cint {.cdecl,
    importc: "glfwWindowShouldClose", glfwImport.}
proc setWindowShouldClose*(window: GLFWwindow; value: cint) {.cdecl,
    importc: "glfwSetWindowShouldClose", glfwImport.}
proc setWindowTitle*(window: GLFWwindow; title: cstring) {.cdecl,
    importc: "glfwSetWindowTitle", glfwImport.}
proc getWindowPos*(window: GLFWwindow; xpos: ptr cint; ypos: ptr cint) {.
    cdecl, importc: "glfwGetWindowPos", glfwImport.}
proc setWindowPos*(window: GLFWwindow; xpos: cint; ypos: cint) {.cdecl,
    importc: "glfwSetWindowPos", glfwImport.}
proc getWindowSize*(window: GLFWwindow; width: ptr cint; height: ptr cint) {.
    cdecl, importc: "glfwGetWindowSize", glfwImport.}
proc setWindowSize*(window: GLFWwindow; width: cint; height: cint) {.
    cdecl, importc: "glfwSetWindowSize", glfwImport.}
proc getFramebufferSize*(window: GLFWwindow; width: ptr cint;
                         height: ptr cint) {.cdecl,
    importc: "glfwGetFramebufferSize", glfwImport.}
proc iconifyWindow*(window: GLFWwindow) {.cdecl,
    importc: "glfwIconifyWindow", glfwImport.}
proc restoreWindow*(window: GLFWwindow) {.cdecl,
    importc: "glfwRestoreWindow", glfwImport.}
proc showWindow*(window: GLFWwindow) {.cdecl, importc: "glfwShowWindow",
    glfwImport.}
proc hideWindow*(window: GLFWwindow) {.cdecl, importc: "glfwHideWindow",
    glfwImport.}
proc getWindowMonitor*(window: GLFWwindow): GLFWmonitor {.cdecl,
    importc: "glfwGetWindowMonitor", glfwImport.}
proc getWindowAttrib*(window: GLFWwindow; attrib: cint): cint {.cdecl,
    importc: "glfwGetWindowAttrib", glfwImport.}
proc setWindowUserPointer*(window: GLFWwindow; pointer: pointer) {.cdecl,
    importc: "glfwSetWindowUserPointer", glfwImport.}
proc getWindowUserPointer*(window: GLFWwindow): pointer {.cdecl,
    importc: "glfwGetWindowUserPointer", glfwImport.}
proc setWindowPosCallback*(window: GLFWwindow; cbfun: GLFWwindowposfun): GLFWwindowposfun {.
    cdecl, importc: "glfwSetWindowPosCallback", glfwImport.}
proc setWindowSizeCallback*(window: GLFWwindow; cbfun: GLFWwindowsizefun): GLFWwindowsizefun {.
    cdecl, importc: "glfwSetWindowSizeCallback", glfwImport.}
proc setWindowCloseCallback*(window: GLFWwindow; cbfun: GLFWwindowclosefun): GLFWwindowclosefun {.
    cdecl, importc: "glfwSetWindowCloseCallback", glfwImport.}
proc setWindowRefreshCallback*(window: GLFWwindow;
                               cbfun: GLFWwindowrefreshfun): GLFWwindowrefreshfun {.
    cdecl, importc: "glfwSetWindowRefreshCallback", glfwImport.}
proc setWindowFocusCallback*(window: GLFWwindow; cbfun: GLFWwindowfocusfun): GLFWwindowfocusfun {.
    cdecl, importc: "glfwSetWindowFocusCallback", glfwImport.}
proc setWindowIconifyCallback*(window: GLFWwindow;
                               cbfun: GLFWwindowiconifyfun): GLFWwindowiconifyfun {.
    cdecl, importc: "glfwSetWindowIconifyCallback", glfwImport.}
proc setFramebufferSizeCallback*(window: GLFWwindow;
                                 cbfun: GLFWframebuffersizefun): GLFWframebuffersizefun {.
    cdecl, importc: "glfwSetFramebufferSizeCallback", glfwImport.}
proc pollEvents*() {.cdecl, importc: "glfwPollEvents", glfwImport.}
proc waitEvents*() {.cdecl, importc: "glfwWaitEvents", glfwImport.}
proc getInputMode*(window: GLFWwindow; mode: cint): cint {.cdecl,
    importc: "glfwGetInputMode", glfwImport.}
proc setInputMode*(window: GLFWwindow; mode: cint; value: cint) {.cdecl,
    importc: "glfwSetInputMode", glfwImport.}
proc getKey*(window: GLFWwindow; key: cint): cint {.cdecl,
    importc: "glfwGetKey", glfwImport.}
proc getMouseButton*(window: GLFWwindow; button: cint): cint {.cdecl,
    importc: "glfwGetMouseButton", glfwImport.}
proc getCursorPos*(window: GLFWwindow; xpos: ptr cdouble;
                   ypos: ptr cdouble) {.cdecl, importc: "glfwGetCursorPos",
    glfwImport.}
proc setCursorPos*(window: GLFWwindow; xpos: cdouble; ypos: cdouble) {.
    cdecl, importc: "glfwSetCursorPos", glfwImport.}
proc setKeyCallback*(window: GLFWwindow; cbfun: GLFWkeyfun): GLFWkeyfun {.
    cdecl, importc: "glfwSetKeyCallback", glfwImport.}
proc setCharCallback*(window: GLFWwindow; cbfun: GLFWcharfun): GLFWcharfun {.
    cdecl, importc: "glfwSetCharCallback", glfwImport.}
proc setMouseButtonCallback*(window: GLFWwindow; cbfun: GLFWmousebuttonfun): GLFWmousebuttonfun {.
    cdecl, importc: "glfwSetMouseButtonCallback", glfwImport.}
proc setCursorPosCallback*(window: GLFWwindow; cbfun: GLFWcursorposfun): GLFWcursorposfun {.
    cdecl, importc: "glfwSetCursorPosCallback", glfwImport.}
proc setCursorEnterCallback*(window: GLFWwindow; cbfun: GLFWcursorenterfun): GLFWcursorenterfun {.
    cdecl, importc: "glfwSetCursorEnterCallback", glfwImport.}
proc setScrollCallback*(window: GLFWwindow; cbfun: GLFWscrollfun): GLFWscrollfun {.
    cdecl, importc: "glfwSetScrollCallback", glfwImport.}
proc joystickPresent*(joy: cint): cint {.cdecl,
    importc: "glfwJoystickPresent", glfwImport.}
proc getJoystickAxes*(joy: cint; count: ptr cint): ptr cfloat {.cdecl,
    importc: "glfwGetJoystickAxes", glfwImport.}
proc getJoystickButtons*(joy: cint; count: ptr cint): ptr cuchar {.cdecl,
    importc: "glfwGetJoystickButtons", glfwImport.}
proc getJoystickName*(joy: cint): cstring {.cdecl,
    importc: "glfwGetJoystickName", glfwImport.}
proc setClipboardString*(window: GLFWwindow; string: cstring) {.cdecl,
    importc: "glfwSetClipboardString", glfwImport.}
proc getClipboardString*(window: GLFWwindow): cstring {.cdecl,
    importc: "glfwGetClipboardString", glfwImport.}
proc getTime*(): cdouble {.cdecl, importc: "glfwGetTime", glfwImport.}
proc setTime*(time: cdouble) {.cdecl, importc: "glfwSetTime", glfwImport.}
proc makeContextCurrent*(window: GLFWwindow) {.cdecl,
    importc: "glfwMakeContextCurrent", glfwImport.}
proc getCurrentContext*(): GLFWwindow {.cdecl,
    importc: "glfwGetCurrentContext", glfwImport.}
proc swapBuffers*(window: GLFWwindow) {.cdecl, importc: "glfwSwapBuffers",
    glfwImport.}
proc swapInterval*(interval: cint) {.cdecl, importc: "glfwSwapInterval",
                                     glfwImport.}
proc extensionSupported*(extension: cstring): cint {.cdecl,
    importc: "glfwExtensionSupported", glfwImport.}
proc getProcAddress*(procname: cstring): GLFWglproc {.cdecl,
    importc: "glfwGetProcAddress", glfwImport.}
