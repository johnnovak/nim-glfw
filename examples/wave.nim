#------------------------------------------------------------------------
# Nim port of the GLFW example 'wave.c'
# https://github.com/glfw/glfw/blob/master/examples/wave.c
#
# Ported by John Novak <john@johnnovak.net>
#
# Requires nim-glm.
#------------------------------------------------------------------------

#****************************************************************************
# Wave Simulation in OpenGL
# (C) 2002 Jakob Thomsen
# http://home.in.tum.de/~thomsen
# Modified for GLFW by Sylvain Hellegouarch - sh@programmationworld.com
# Modified for variable frame rate by Marcus Geelnard
# 2003-Jan-31: Minor cleanups and speedups / MG
# 2010-10-24: Formatting and cleanup - Camilla Berglund
#****************************************************************************/

import math

import glm
import glad/gl
import glfw
import glfw/wrapper


type Vertex = object
  x, y, z: GLfloat
  r, g, b: GLfloat

const
  # Maximum delta T to allow for differential calculations
  MAX_DELTA_T = 0.01

  # Animation speed (10.0 looks good)
  ANIMATION_SPEED = 10.0

  GRIDW = 50
  GRIDH = 50
  VERTEXNUM = GRIDW * GRIDH

  QUADW = GRIDW - 1
  QUADH = GRIDH - 1
  QUADNUM = QUADW * QUADH


var
  alpha = 210.0
  beta  = -70.0
  zoom  = 2.0

  cursorX: float64
  cursorY: float64

  quad: array[4 * QUADNUM, GLuint]
  vertex: array[VERTEXNUM, Vertex]

  dt: float64


# The grid will look like this:
#
#      3   4   5
#      *---*---*
#      |   |   |
#      | 0 | 1 |
#      |   |   |
#      *---*---*
#      0   1   2
#

#========================================================================
# Initialize grid geometry
#========================================================================

proc initVertices() =
  # Place the vertices in a grid
  for y in 0..GRIDH-1:
    for x in 0..GRIDW-1:
      var p = y * GRIDW + x

      vertex[p].x = (GLfloat(x) - GRIDW / 2) / (GRIDW / 2)
      vertex[p].y = (GLfloat(y) - GRIDH / 2) / (GRIDH / 2)
      vertex[p].z = 0

      if (x mod 4 < 2) xor (y mod 4 < 2):
        vertex[p].r = 0.0
      else:
        vertex[p].r = 1.0

      vertex[p].g = y / GRIDH
      vertex[p].b = 1.0 - (GLfloat(x) / GRIDW + GLfloat(y) / GRIDH) / 2

  for y in 0..QUADH-1:
    for x in 0..QUADW-1:
      var p = 4 * (y * QUADW + x)

      quad[p+0] = GLuint(y     * GRIDW + x  )  # Some point
      quad[p+1] = GLuint(y     * GRIDW + x+1)  # Neighbor at the right side
      quad[p+2] = GLuint((y+1) * GRIDW + x+1)  # Upper right neighbor
      quad[p+3] = GLuint((y+1) * GRIDW + x  )  # Upper neighbor

#========================================================================
# Initialize grid
#========================================================================

var
  p, vx, vy, ax, ay: array[GRIDW, array[GRIDH, float64]]


proc initGrid() =
  for y in 0..GRIDH-1:
    for x in 0..GRIDW-1:
      var
        dx = float64(x) - GRIDW / 2
        dy = float64(y) - GRIDH / 2
        d = sqrt(dx * dx + dy * dy)

      if d < 0.1 * (GRIDW / 2):
        d = d * 10.0
        p[x][y] = -cos(d * (PI / (GRIDW * 4))) * 100.0
      else:
        p[x][y] = 0.0

      vx[x][y] = 0.0
      vy[x][y] = 0.0


#========================================================================
# Draw scene
#========================================================================

proc drawScene(win: Win) =
  # Clear the color and depth buffers
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

  # We don't want to modify the projection matrix
  glMatrixMode(GL_MODELVIEW)
  glLoadIdentity()

  # Move back
  glTranslatef(0.0, 0.0, -zoom)
  # Rotate the view
  glRotatef(beta, 1.0, 0.0, 0.0)
  glRotatef(alpha, 0.0, 0.0, 1.0)

  glDrawElements(GL_QUADS, 4 * QUADNUM, GL_UNSIGNED_INT, quad.addr)

  glfw.swapBufs(win)


#========================================================================
# Initialize Miscellaneous OpenGL state
#========================================================================

proc initOpenGL() =
  # Use Gouraud (smooth) shading
  glShadeModel(GL_SMOOTH)

  # Switch on the z-buffer
  glEnable(GL_DEPTH_TEST)

  glEnableClientState(GL_VERTEX_ARRAY)
  glEnableClientState(GL_COLOR_ARRAY)

  glVertexPointer(3, cGL_FLOAT, GLsizei(sizeof(Vertex)), vertex.addr)

  glColorPointer(3, cGL_FLOAT, GLsizei(sizeof(Vertex)),
                 vertex[0].r.addr)  # Pointer to the first color

  glPointSize(2.0)

  # Background color is black
  glClearColor(0, 0, 0, 0)


#========================================================================
# Modify the height of each vertex according to the pressure
#========================================================================

proc adjustGrid() =
  for y in 0..GRIDH-1:
    for x in 0..GRIDW-1:
      var pos = y * GRIDW + x
      vertex[pos].z = p[x][y] * (1.0 / 50.0)


#========================================================================
# Calculate wave propagation
#========================================================================

proc calcGrid() =
  var
    timeStep: float64 = dt * ANIMATION_SPEED

  # Compute accelerations
  for x in 0..GRIDW-1:
    var x2 = (x + 1) mod GRIDW
    for y in 0..GRIDH-1:
      ax[x][y] = p[x][y] - p[x2][y]

  for y in 0..GRIDH-1:
    var y2 = (y + 1) mod GRIDH
    for x in 0..GRIDW-1:
      ay[x][y] = p[x][y] - p[x][y2]

  # Compute speeds
  for x in 0..GRIDW-1:
    for y in 0..GRIDH-1:
      vx[x][y] += ax[x][y] * timeStep
      vy[x][y] += ay[x][y] * timeStep

  #/ Compute pressure
  for x in 1..GRIDW-1:
    var x2 = x - 1
    for y in 1..GRIDH-1:
      var y2 = y - 1
      p[x][y] += (vx[x2][y] - vx[x][y] + vy[x][y2] - vy[x][y]) * timeStep


#========================================================================
# Handle key strokes
#========================================================================

proc keyCb(win: Win, key: Key, scanCode: int, action: KeyAction,
           modKeys: ModifierKeySet) =

  if action != kaDown: return

  case key
  of keyEscape: win.shouldClose = true
  of keySpace:  initGrid()
  of keyLeft:   alpha += 5
  of keyRight:  alpha -= 5
  of keyUp:     beta -= 5
  of keyDown:   beta += 5
  of keyPageUp:
    zoom -= 0.25
    if (zoom < 0.0): zoom = 0.0
  of keyPageDown:
    zoom += 0.25
  else: return

#========================================================================
# Callback function for mouse button events
#========================================================================

proc mouseBtnCb(win: Win, btn: MouseBtn, pressed: bool,
                modKeys: ModifierKeySet) =

  if btn != mbLeft:
    return

  if pressed:
    win.cursorMode = cmDisabled
    (cursorx, cursory) = win.cursorPos
  else:
    win.cursorMode = cmNormal


#========================================================================
# Callback function for cursor motion events
#========================================================================

proc cursorPosCb(win: Win, pos: tuple[x, y: float64]) =
  if win.cursorMode == cmDisabled:
    alpha += (pos.x - cursorX) / 10
    beta += (pos.y - cursorY) / 10

    cursorX = pos.x
    cursorY = pos.y

#========================================================================
# Callback function for scroll events
#========================================================================

proc scrollCb(win: Win, pos: tuple[x, y: float64]) =
  zoom += pos.y / 4
  if zoom < 0:
    zoom = 0

#========================================================================
# Callback function for framebuffer resize events
#========================================================================

proc reshape(win: Win, res: tuple[w, h: int]) =
  var ratio = 1.0
  if res.h > 0:
    ratio = res.w / res.h

  # Setup viewport
  glViewport(0, 0, GLsizei(res.w), GLsizei(res.h))

  # Change to the projection matrix and set our viewing volume
  glMatrixMode(GL_PROJECTION)

  var projection = perspective[GLfloat](
    fovy = 60.0 * PI / 180.0,
    ratio,
    zNear = 1.0, zFar = 1024.0)

  glLoadMatrixf(projection.caddr)


#========================================================================
# main
#========================================================================

proc main() =
  # Initialise GLFW
  glfw.init()

  # Open OpenGL window
  var win = newGlWin(
    dim = (w: 640, h: 480),
    title = "Wave Simulation",
    resizable = true,
    version = glv20
  )

  # Set callback functions
  win.keyCb = keyCb
  win.framebufSizeCb = reshape
  win.mouseBtnCb = mouseBtnCb
  win.cursorPosCb = cursorPosCb
  win.scrollCb = scrollCb

  glfw.makeContextCurrent(win)

  if not gladLoadGL(getProcAddress):
    quit "Error initialising OpenGL"

  glfw.swapInterval(1)

  var width, height: int
  (width, height) = framebufSize(win)
  win.reshape((width, height))

  # Initialize OpenGL
  initOpenGL()

  # Initialize simulation
  initVertices()
  initGrid()
  adjustGrid()

  # Initialize timer
  var
    t, dtTotal: float64
    tOld = getTime() - 0.01

  while not win.shouldClose:
    t = getTime()
    dtTotal = t - tOld
    tOld = t

    # Safety - iterate if dtTotal is too large
    while dtTotal > 0.0:
      # Select iteration time step
      dt = (if dtTotal > MAX_DELTA_T: MAX_DELTA_T else: dtTotal)
      dtTotal -= dt

      # Calculate wave propagation
      calcGrid()

    # Compute height of each vertex
    adjustGrid()

    # Draw wave grid to OpenGL display
    drawScene(win)

    glfw.pollEvents()


main()

