import os, glfw

proc main =
  glfw.initialize()

  var c = DefaultOpenglWindowConfig

  c.title = "Minimal Nim-GLFW example"
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

  sleep(1000)
  w.destroy()
  glfw.terminate()

main()
