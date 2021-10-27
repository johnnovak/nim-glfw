#------------------------------------------------------------------------
# Nim port of the GLFW example 'splitview.c'
# https://github.com/glfw/glfw/blob/master/examples/splitview.c
#
# Ported by John Novak <john@johnnovak.net>
#
# Requires nim-glm.
#------------------------------------------------------------------------

#========================================================================
# This is an example program for the GLFW library
#
# The program uses a "split window" view, rendering four views of the
# same scene in one window (e.g. uesful for 3D modelling software). This
# demo uses scissors to separete the four different rendering areas from
# each other.
#
# (If the code seems a little bit strange here and there, it may be
#  because I am not a friend of orthogonal projections)
#========================================================================

import math

import glad/gl
import glm
import glfw


#========================================================================
# Global variables
#========================================================================

var
  # Mouse position
  xpos = 0.0
  ypos = 0.0

  # Window size
  width, height: int

  # Active view: 0 = none, 1 = upper left, 2 = upper right, 3 = lower left,
  # 4 = lower right
  activeView = 0

  # Rotation around each axis
  rotX = 0
  rotY = 0
  rotZ = 0

  # Do redraw?
  doRedraw = true

  torusList: GLuint = 0

#========================================================================
# Draw a solid torus (use a display list for the model)
#========================================================================

const
  TORUS_MAJOR     = 1.5
  TORUS_MINOR     = 0.5
  TORUS_MAJOR_RES = 32
  TORUS_MINOR_RES = 32

proc drawTorus() =
  if torusList == 0:
    # Start recording displaylist
    torusList = glGenLists(1)
    glNewList(torusList, GL_COMPILE_AND_EXECUTE)

    # Draw torus
    let TWOPI = 2.0 * PI

    for i in 0..TORUS_MINOR_RES-1:
      glBegin(GL_QUAD_STRIP)

      for j in 0..TORUS_MAJOR_RES:
        for k in countdown(1, 0):
          var
            s = float((i + k) mod TORUS_MINOR_RES) + 0.5
            t = float(j mod TORUS_MAJOR_RES)

            # Calculate point on surface
            xz1 = TORUS_MAJOR + TORUS_MINOR * cos(s * TWOPI / TORUS_MINOR_RES)

            x = xz1         * cos(t * TWOPI / TORUS_MAJOR_RES)
            y = TORUS_MINOR * sin(s * TWOPI / TORUS_MINOR_RES)
            z = xz1         * sin(t * TWOPI / TORUS_MAJOR_RES)

            # Calculate surface normal
            nx = x - TORUS_MAJOR * cos(t * TWOPI / TORUS_MAJOR_RES)
            ny = y
            nz = z - TORUS_MAJOR * sin(t * TWOPI / TORUS_MAJOR_RES)

            scale = 1.0 / sqrt(nx*nx + ny*ny + nz*nz)

          nx *= scale
          ny *= scale
          nz *= scale

          glNormal3f(nx, ny, nz)
          glVertex3f(x, y, z)

      glEnd()

    # Stop recording displaylist
    glEndList()
  else:
    # Playback displaylist
    glCallList(torusList)


#========================================================================
# Draw the scene (a rotating torus)
#========================================================================

proc drawScene() =
  var
    modelDiffuse   = vec4[GLfloat](1.0, 0.8, 0.8, 1.0)
    modelSpecular  = vec4[GLfloat](0.6, 0.6, 0.6, 1.0)
    modelShininess = 20.0

  glPushMatrix()

  # Rotate the object
  glRotatef(float(rotX) * 0.5, 1.0, 0.0, 0.0)
  glRotatef(float(rotY) * 0.5, 0.0, 1.0, 0.0)
  glRotatef(float(rotZ) * 0.5, 0.0, 0.0, 1.0)

  # Set model color (used for orthogonal views, lighting disabled)
  glColor4fv(modelDiffuse.caddr)

  # Set model material (used for perspective view, lighting enabled)
  glMaterialfv(GL_FRONT, GL_DIFFUSE, modelDiffuse.caddr)
  glMaterialfv(GL_FRONT, GL_SPECULAR, modelSpecular.caddr)
  glMaterialf(GL_FRONT, GL_SHININESS, modelShininess)

  # Draw torus
  drawTorus()

  glPopMatrix()


#========================================================================
# Draw a 2D grid (used for orthogonal views)
#========================================================================

proc drawGrid(scale: float, steps: int) =
  glPushMatrix()

  # Set background to some dark bluish grey
  glClearColor(0.05, 0.05, 0.2, 0.0)
  glClear(GL_COLOR_BUFFER_BIT)

  # Setup modelview matrix (flat XY view)
  var
    eye = vec3[GLfloat](0.0, 0.0, 1.0)
    center = vec3[GLfloat](0.0, 0.0, 0.0)
    up = vec3[GLfloat](0.0, 1.0, 0.0)
    view = lookAt[GLfloat](eye, center, up)

  glLoadMatrixf(view.caddr)

  # We don't want to update the Z-buffer
  glDepthMask(false)

  # Set grid color
  glColor3f(0.0, 0.5, 0.5)

  glBegin(GL_LINES)

  # Horizontal lines
  var
    x = scale * 0.5 * float(steps - 1)
    y = -scale * 0.5 * float(steps - 1)

  for i in 0..steps-1:
    glVertex3f(-x, y, 0.0)
    glVertex3f(x, y, 0.0)
    y += scale

  # Vertical lines
  x = -scale * 0.5 * float(steps - 1)
  y = scale * 0.5 * float(steps - 1)

  for i in 0..steps-1:
    glVertex3f(x, -y, 0.0)
    glVertex3f(x, y, 0.0)
    x += scale

  glEnd()

  # Enable Z-buffer writing again
  glDepthMask(true)

  glPopMatrix()


#========================================================================
# Draw all views
#========================================================================

proc drawAllViews() =
  var
    lightPosition = vec4[GLfloat](0.0, 8.0, 8.0, 1.0)
    lightDiffuse  = vec4[GLfloat](1.0, 1.0, 1.0, 1.0)
    lightSpecular = vec4[GLfloat](1.0, 1.0, 1.0, 1.0)
    lightAmbient  = vec4[GLfloat](0.2, 0.2, 0.3, 1.0)

  # Calculate aspect of window
  var aspect: float

  if height > 0:
    aspect = width / height
  else:
    aspect = 1.0

  # Clear screen
  glClearColor(0.0, 0.0, 0.0, 0.0)
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

  # Enable scissor test
  glEnable(GL_SCISSOR_TEST)

  # Enable depth test
  glEnable(GL_DEPTH_TEST)
  glDepthFunc(GL_LEQUAL)

  # ** ORTHOGONAL VIEWS **

  # For orthogonal views, use wireframe rendering
  glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)

  # Enable line anti-aliasing
  glEnable(GL_LINE_SMOOTH)
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

  # Setup orthogonal projection matrix
  glMatrixMode(GL_PROJECTION)
  glLoadIdentity()
  glOrtho(-3.0 * aspect, 3.0 * aspect, -3.0, 3.0, 1.0, 50.0)

  # Upper left view (TOP VIEW)
  let
    halfHeight = GLsizei(height / 2)
    halfWidth = GLsizei(width / 2)

  glViewport(0, halfHeight, halfWidth, halfHeight)
  glScissor(0, halfHeight, halfWidth, halfHeight)
  glMatrixMode(GL_MODELVIEW)

  var
    eye = vec3[GLfloat](0.0, 10.0, 1e-3)
    center = vec3[GLfloat](0.0, 0.0, 0.0)
    up = vec3[GLfloat](0.0, 1.0, 0.0)
    view = lookAt[GLfloat](eye, center, up)

  glLoadMatrixf(view.caddr)
  drawGrid(0.5, 12)
  drawScene()

  # Lower left view (FRONT VIEW)
  glViewport(0, 0, halfWidth, halfHeight)
  glScissor(0, 0, halfWidth, halfHeight)
  glMatrixMode(GL_MODELVIEW)

  eye = vec3[GLfloat](0.0, 0.0, 10.0)
  center = vec3[GLfloat](0.0, 0.0, 0.0)
  up = vec3[GLfloat](0.0, 1.0, 0.0)
  view = lookAt[GLfloat](eye, center, up)

  glLoadMatrixf(view.caddr)
  drawGrid(0.5, 12)
  drawScene()

  # Lower right view (SIDE VIEW)
  glViewport(halfWidth, 0, halfWidth, halfHeight)
  glScissor(halfWidth, 0, halfWidth, halfHeight)
  glMatrixMode(GL_MODELVIEW)

  eye = vec3[GLfloat](10.0, 0.0, 0.0)
  center = vec3[GLfloat](0.0, 0.0, 0.0)
  up = vec3[GLfloat](0.0, 1.0, 0.0)
  view = lookAt[GLfloat](eye, center, up)

  glLoadMatrixf(view.caddr)
  drawGrid(0.5, 12)
  drawScene()

  # Disable line anti-aliasing
  glDisable(GL_LINE_SMOOTH)
  glDisable(GL_BLEND)

  # ** PERSPECTIVE VIEW **

  # For perspective view, use solid rendering
  glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)

  # Enable face culling (faster rendering)
  glEnable(GL_CULL_FACE)
  glCullFace(GL_BACK)
  glFrontFace(GL_CW)

  # Setup perspective projection matrix
  glMatrixMode(GL_PROJECTION)

  var projection = perspective[GLfloat](
     fovy = 65.0 * PI / 180.0,
     aspect,
     zNear = 1.0, zFar = 50.0)

  glLoadMatrixf(projection.caddr)

  # Upper right view (PERSPECTIVE VIEW)
  glViewport(halfWidth, halfHeight, halfWidth, halfHeight)
  glScissor(halfWidth, halfHeight, halfWidth, halfHeight)
  glMatrixMode(GL_MODELVIEW)

  eye = vec3[GLfloat](3.0, 1.5, 3.0)
  center = vec3[GLfloat](0.0, 0.0, 0.0)
  up = vec3[GLfloat](0.0, 1.0, 0.0)
  view = lookAt[GLfloat](eye, center, up)

  glLoadMatrixf(view.caddr)

  # Configure and enable light source 1
  glLightfv(GL_LIGHT1, GL_POSITION, lightPosition.caddr)
  glLightfv(GL_LIGHT1, GL_AMBIENT, lightAmbient.caddr)
  glLightfv(GL_LIGHT1, GL_DIFFUSE, lightDiffuse.caddr)
  glLightfv(GL_LIGHT1, GL_SPECULAR, lightSpecular.caddr)
  glEnable(GL_LIGHT1)
  glEnable(GL_LIGHTING)

  # Draw scene
  drawScene()

  # Disable lighting
  glDisable(GL_LIGHTING)

  # Disable face culling
  glDisable(GL_CULL_FACE)

  # Disable depth test
  glDisable(GL_DEPTH_TEST)

  # Disable scissor test
  glDisable(GL_SCISSOR_TEST)

  # Draw a border around the active view
  if activeView > 0 and activeView != 2:
    glViewport(0, 0, GLsizei(width), GLsizei(height))

    glMatrixMode(GL_PROJECTION)
    glLoadIdentity()
    glOrtho(0.0, 2.0, 0.0, 2.0, 0.0, 1.0)

    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity()
    glTranslatef(GLfloat((activeView - 1) and 1),
                 ceil(1 - (activeView - 1) / 2),
                 0.0)

    glColor3f(1.0, 1.0, 0.6)

    glBegin(GL_LINE_STRIP)
    glVertex2i(0, 0)
    glVertex2i(1, 0)
    glVertex2i(1, 1)
    glVertex2i(0, 1)
    glVertex2i(0, 0)
    glEnd()


#========================================================================
# Framebuffer size callback function
#========================================================================

proc reshape(win: Window, res: tuple[w, h: int32]) =
  width  = res.w
  height = if res.h > 0: res.h else: 1
  doRedraw = true


#========================================================================
# Window refresh callback function
#========================================================================

proc windowRefreshCb(win: Window) =
  drawAllViews()
  glfw.swapBuffers(win)
  doRedraw = false


#========================================================================
# Mouse position callback function
#========================================================================

proc cursorPositionCb(win: Window, pos: tuple[x, y: float64]) =
  var
    wndWidth, wndHeight, fbWidth, fbHeight: int

  (wndWidth, wndHeight) = size(win)
  (fbWidth, fbHeight) = framebufferSize(win)

  var
    scale = fbWidth / wndWidth
    x = pos.x * scale
    y = pos.y * scale

  # Depending on which view was selected, rotate around different axes
  case activeView
  of 1:
    rotX += int(y - ypos)
    rotZ += int(x - xpos)
    doRedraw = true
  of 3:
    rotX += int(y - ypos)
    rotY += int(x - xpos)
    doRedraw = true
  of 4:
    rotY += int(x - xpos)
    rotZ += int(y - ypos)
    doRedraw = true
  else:
    # Do nothing for perspective view, or if no view is selected
    discard

  # Remember cursor position
  xpos = x
  ypos = y


#========================================================================
# Mouse button callback function
#========================================================================

proc mouseButtonCb(win: Window, btn: MouseButton, pressed: bool,
                modKeys: set[ModifierKey]) =

  if btn == mbLeft and pressed:
    # Detect which of the four views was clicked
    activeView = 1
    if xpos >= width / 2:
      activeView += 1
    if ypos >= height / 2:
      activeView += 2

  else:
    if btn == mbLeft:
      # Deselect any previously selected view
      activeView = 0

  doRedraw = true

proc keyCb(win: Window, key: Key, scanCode: int32, action: KeyAction,
           modKeys: set[ModifierKey]) =

  if key == keyEscape and action == kaUp:
    win.shouldClose = true


#========================================================================
# main
#========================================================================

proc main() =
  # Initialise GLFW
  glfw.initialize()

  # Open OpenGL window
  var cfg = DefaultOpenglWindowConfig
  cfg.size = (w: 500, h: 500)
  cfg.title = "Split view demo"
  cfg.resizable = true
  cfg.nMultiSamples = 4
  cfg.version = glv20
  var win = newWindow(cfg)

  # Set callback functions
  win.framebufferSizeCb = reshape
  win.windowRefreshCb = windowRefreshCb
  win.cursorPositionCb = cursorPositionCb
  win.mouseButtonCb = mouseButtonCb
  win.keyCb = keyCb

  if not gladLoadGL(getProcAddress):
    quit "Error initialising OpenGL"

  # Enable vsync
  glfw.swapInterval(1)

  if GLAD_GL_ARB_multisample or GLAD_GL_VERSION_1_3:
    glEnable(GL_MULTISAMPLE_ARB)

  let (w, h) = framebufferSize(win)
  win.reshape((w, h))

  # Main loop
  while true:
    # Only redraw if we need to
    if doRedraw:
      windowRefreshCb(win)

    # Wait for new events
    glfw.waitEvents()

    # Check if the window should be closed
    if win.shouldClose:
      break

  # Close OpenGL window and terminate GLFW
  glfw.terminate()


main()
