#------------------------------------------------------------------------
# Nim port of the GLFW example 'boing.c'
# https://github.com/glfw/glfw/blob/master/examples/boing.c
#
# Ported by John Novak <john@johnnovak.net>
#
# Requires nim-glm.
#------------------------------------------------------------------------

#*****************************************************************************
#  Title:   GLBoing
#  Desc:    Tribute to Amiga Boing.
#  Author:  Jim Brooks  <gfx@jimbrooks.org>
#           Original Amiga authors were R.J. Mical and Dale Luck.
#           GLFW conversion by Marcus Geelnard
#  Notes:   - 360' = 2*PI [radian]
#
#           - Distances between objects are created by doing a relative
#             Z translations.
#
#           - Although OpenGL enticingly supports alpha-blending,
#             the shadow of the original Boing didn't affect the color
#             of the grid.
#
#           - [Marcus] Changed timing scheme from interval driven to frame-
#             time based animation steps (which results in much smoother
#             movement)
#
#  History of Amiga Boing:
#
#  Boing was demonstrated on the prototype Amiga (codenamed "Lorraine") in
#  1985. According to legend, it was written ad-hoc in one night by
#  R. J. Mical and Dale Luck. Because the bouncing ball animation was so fast
#  and smooth, attendees did not believe the Amiga prototype was really doing
#  the rendering. Suspecting a trick, they began looking around the booth for
#  a hidden computer or VCR.
#*****************************************************************************

import std/math
import std/random

import glm
import glad/gl
import glfw


#*****************************************************************************
# Various declarations and macros
#*****************************************************************************

proc drawBoingBall()
proc drawGrid()
proc bounceBall(deltaT: float64)
proc drawBoingBallBand(longLo, longHi: GLfloat)

let
  RADIUS          = 70.0
  STEP_LONGITUDE  = 22.5            # 22.5 makes 8 bands like original Boing
  STEP_LATITUDE   = 22.5
  DIST_BALL       = (RADIUS * 2.0 + RADIUS * 0.1)

  # distance from viewer to middle of boing area
  VIEW_SCENE_DIST = (DIST_BALL * 3 + 200.0)

  GRID_SIZE       = (RADIUS * 4.5)  # length (width) of grid
  BOUNCE_HEIGHT   = (RADIUS * 2.1)
  BOUNCE_WIDTH    = (RADIUS * 2.1)

  SHADOW_OFFSET_X = -20.0
  SHADOW_OFFSET_Y =  10.0
  SHADOW_OFFSET_Z =   0.0

  WALL_L_OFFSET   = 0.0
  WALL_R_OFFSET   = 5.0

  # Animation speed (50.0 mimics the original GLUT demo speed)
  ANIMATION_SPEED = 50.0

  # Maximum allowed delta time per physics iteration
  MAX_DELTA_T     = 0.02


# Draw ball, or its shadow
type
  DrawBallEnum = enum
    dbBall, dbShadow

  Vertex = object
    x, y, z: GLfloat


# Global vars
var
  windowedXPos, windowedYPos, windowedWidth, windowedHeight: int32
  width, height: int

  degRotY     = 0.0
  degRotYInc  = 2.0
  overridePos = false
  cursorX     = 0.0
  cursorY     = 0.0
  ballX       = -RADIUS
  ballY       = -RADIUS
  ballXInc    = 1.0
  ballYInc    = 2.0
  drawBallHow: DrawBallEnum
  t, dt: float64
  tOld = 0.0


#*****************************************************************************
# Truncate a degree.
#*****************************************************************************
proc truncateDeg(deg: GLfloat): GLfloat =
  if deg >= 360.0:
    result = deg - 360.0
  else:
    result = deg

#*****************************************************************************
# 360' sin().
#*****************************************************************************
proc sinDeg(deg: float64): float64 = sin(degToRad(deg))

#*****************************************************************************
# 360' cos().
#*****************************************************************************
proc cosDeg(deg: float64): float64 = cos(degToRad(deg))

#*****************************************************************************
# Compute a cross product (for a normal vector).
#
# c = a x b
#*****************************************************************************
proc crossProduct(a, b, c: Vertex, n: var Vertex) =
  let
    u1 = b.x - a.x
    u2 = b.y - a.y
    u3 = b.y - a.z

    v1 = c.x - a.x
    v2 = c.y - a.y
    v3 = c.z - a.z

  n.x = u2 * v3 - v2 * v3
  n.y = u3 * v1 - v3 * u1
  n.z = u1 * v2 - v1 * u2


#*****************************************************************************
#* init()
#*****************************************************************************
proc init() =
  # Clear background.
  glClearColor(0.55, 0.55, 0.55, 0.0)

  glShadeModel(GL_FLAT)


#*****************************************************************************
#* display()
#*****************************************************************************
proc display() =
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  glPushMatrix()

  drawBallHow = dbShadow
  drawBoingBall()

  drawGrid()

  drawBallHow = dbBall
  drawBoingBall()

  glPopMatrix()
  glFlush()


#*****************************************************************************
#* reshape()
#*****************************************************************************
proc reshape(win: Window, res: tuple[w, h: int32]) =
  glViewport(0, 0, GLsizei(res.w), GLsizei(res.h))

  glMatrixMode(GL_PROJECTION)

  var projection = perspective[GLfloat](
    fovy = 2.0 * arctan2(RADIUS, 200.0),
    aspect = res.w / res.h,
    zNear = 1.0,
    zFar = VIEW_SCENE_DIST)

  glLoadMatrixf(projection.caddr)

  glMatrixMode(GL_MODELVIEW)

  let
    eye = vec3[GLfloat](0.0, 0.0, VIEW_SCENE_DIST)
    center = vec3[GLfloat](0.0, 0.0, 0.0)
    up = vec3[GLfloat](0.0, -1.0, 0.0)

  var view = lookAt[GLfloat](eye, center, up)

  glLoadMatrixf(view.caddr)


proc keyCb(win: Window, key: Key, scanCode: int32, action: KeyAction,
           modKeys: set[ModifierKey]) =

  if action != kaDown: return

  if key == keyEscape and modKeys == {}:
    win.shouldClose = true

  if (key == keyEnter and modKeys == {mkAlt}) or
     (key == keyF11   and modKeys == {mkAlt}):

    if win.monitor == NoMonitor:
      let monitor = getPrimaryMonitor()
      if monitor != NoMonitor:
          let mode = monitor.videoMode
          (windowedXPos, windowedYPos) = win.pos
          (windowedWidth, windowedHeight) = win.size

          win.monitor = (
            monitor:     monitor,
            xpos:        0'i32,
            ypos:        0'i32,
            width:       mode.size.w,
            height:      mode.size.h,
            refreshRate: mode.refreshRate
          )
    else:
      win.monitor = (
        monitor:     NoMonitor,
        xpos:        windowedXPos,
        ypos:        windowedYPos,
        width:       windowedWidth,
        height:      windowedHeight,
        refreshRate: 0'i32
      )


proc setBallPos(x, y: GLfloat) =
  ballX = (GLfloat(width) / 2.0) - x
  ballY = y - (GLfloat(height) / 2.0)


proc mouseButtonCb(win: Window, btn: MouseButton, pressed: bool,
                   modKeys: set[ModifierKey]) =

  if btn != mbLeft: return

  if pressed:
    overridePos = true
    setBallPos(cursorX, cursorY)
  else:
    overridePos = false


proc cursorPosCb(win: Window, pos: tuple[x, y: float64]) =
  cursorX = pos.x
  cursorY = pos.y

  if overridePos:
    setBallPos(cursorX, cursorY)


#*****************************************************************************
# Draw the Boing ball.
#*
# The Boing ball is sphere in which each facet is a rectangle.
# Facet colors alternate between red and white.
# The ball is built by stacking latitudinal circles.  Each circle is composed
# of a widely-separated set of points, so that each facet is noticably large.
#*****************************************************************************
proc drawBoingBall() =
  glPushMatrix()
  glMatrixMode(GL_MODELVIEW)

  # Another relative Z translation to separate objects.
  glTranslatef(0.0, 0.0, DIST_BALL)

  # Update ball position and rotation (iterate if necessary)
  var dtTotal, dt2: float64

  dtTotal = dt
  while dtTotal > 0.0:
    dt2 = if dtTotal > MAX_DELTA_T: MAX_DELTA_T else: dtTotal
    dtTotal -= dt2
    bounceBall(dt2)
    degRotY = truncateDeg(degRotY + degRotYInc * (dt2 * ANIMATION_SPEED))

  # Set ball position
  glTranslatef(ballX, ballY, 0.0)

  # Offset the shadow.
  if drawBallHow == dbShadow:
    glTranslatef(SHADOW_OFFSET_X, SHADOW_OFFSET_Y, SHADOW_OFFSET_Z)

  # Tilt the ball.
  glRotatef(-20.0, 0.0, 0.0, 1.0)

  # Continually rotate ball around Y axis.
  glRotatef(degRotY, 0.0, 1.0, 0.0)

  # Set OpenGL state for Boing ball.
  glCullFace(GL_FRONT)
  glEnable(GL_CULL_FACE)
  glEnable(GL_NORMALIZE)

  # Build a faceted latitude slice of the Boing ball,
  # stepping same-sized vertical bands of the sphere.
  var lonDeg = 0.0    # degree of longitudeD

  while lonDeg < 180:
    # Draw a latitude circle at this longitude.
    drawBoingBallBand(lonDeg, lonDeg + STEP_LONGITUDE)
    lonDeg += STEP_LONGITUDE

  glPopMatrix()


#*****************************************************************************
# Bounce the ball.
#*****************************************************************************
proc bounceBall(deltaT: float64) =
  if overridePos:
    return

  # Bounce on walls
  if ballX > BOUNCE_WIDTH / 2 + WALL_R_OFFSET:
     ballXInc = -0.5 - 0.75 * rand(1.0)
     degRotYInc = -degRotYInc

  if ballX < -(BOUNCE_HEIGHT / 2 + WALL_L_OFFSET):
     ballXInc =  0.5 + 0.75 * rand(1.0)
     degRotYInc = -degRotYInc

  # Bounce on floor / roof
  if ballY > BOUNCE_HEIGHT / 2:
     ballYInc = -0.75 - 1.0 * rand(1.0)

  if ballY < -BOUNCE_HEIGHT / 2 * 0.85:
     ballYInc = 0.75 + 1.0 * rand(1.0)

  # Update ball position
  ballX += ballXInc * deltaT * ANIMATION_SPEED
  ballY += ballYInc * deltaT * ANIMATION_SPEED

  # Simulate the effects of gravity on Y movement.
  var deg = (ballY + BOUNCE_HEIGHT / 2) * 90 / BOUNCE_HEIGHT
  if deg > 80: deg = 80
  if deg < 10: deg = 10

  ballYInc = sgn(ballYInc).float * 4 * sinDeg(deg)


#*****************************************************************************
#* Draw a faceted latitude band of the Boing ball.
#*
#* Parms:   longLo, longHi
#*          Low and high longitudes of slice, resp.
#*****************************************************************************
var colorToggle = false

proc drawBoingBallBand(longLo, longHi: GLfloat) =
  # "ne" means south-east, and so on
  var
    vertNE, vertNW, vertSW, vertSE, vertNorm: Vertex
    latDeg = 0.0

  # Iterate thru the points of a latitude circle.
  # A latitude circle is a 2D set of X,Z points.
  while latDeg <= 360 - STEP_LATITUDE:

    # Color this polygon with red or white.
    if colorToggle:
       glColor3f(0.8, 0.1, 0.1)
    else:
       glColor3f(0.95, 0.95, 0.95)

    colorToggle = not colorToggle

    # Change color if drawing shadow.
    if drawBallHow == dbShadow:
       glColor3f(0.35, 0.35, 0.35)

    # Assign each Y.
    vertNW.y = cosDeg(longHi) * RADIUS
    vertNE.y = vertNW.y
    vertSE.y = cosDeg(longLo) * RADIUS
    vertSW.y = vertSE.y

    # Assign each X,Z with sin,cos values scaled by latitude radius indexed by longitude.
    # Eg, long=0 and long=180 are at the poles, so zero scale is sin(longitude),
    # while long=90 (sin(90)=1) is at equator.
    let
      r = RADIUS
      stepLat  = STEP_LATITUDE
      stepLong = STEP_LONGITUDE

    vertNE.x = cosDeg(latDeg          ) * (r * sinDeg(longLo + stepLong))
    vertSE.x = cosDeg(latDeg          ) * (r * sinDeg(longLo           ))
    vertNW.x = cosDeg(latDeg + stepLat) * (r * sinDeg(longLo + stepLong))
    vertSW.x = cosDeg(latDeg + stepLat) * (r * sinDeg(longLo           ))

    vertNE.z = sinDeg(latDeg          ) * (r * sinDeg(longLo + stepLong))
    vertSE.z = sinDeg(latDeg          ) * (r * sinDeg(longLo           ))
    vertNW.z = sinDeg(latDeg + stepLat) * (r * sinDeg(longLo + stepLong))
    vertSW.z = sinDeg(latDeg + stepLat) * (r * sinDeg(longLo           ))

    # Draw the facet.
    glBegin(GL_POLYGON)

    crossProduct(vertNE, vertNW, vertSW, vertNorm)
    glNormal3f(vertNorm.x, vertNorm.y, vertNorm.z)

    glVertex3f(vertNE.x, vertNE.y, vertNE.z)
    glVertex3f(vertNW.x, vertNW.y, vertNW.z)
    glVertex3f(vertSW.x, vertSW.y, vertSW.z)
    glVertex3f(vertSE.x, vertSE.y, vertSE.z)

    glEnd()

    latDeg += stepLat

  # Toggle color so that next band will opposite red/white colors than this one.
  colorToggle = not colorToggle

  # This circular band is done.


#*****************************************************************************
# Draw the purple grid of lines, behind the Boing ball.
# When the Workbench is dropped to the bottom, Boing shows 12 rows.
#*****************************************************************************
proc drawGrid() =
  let
    rowTotal  = 12                  # must be divisible by 2
    colTotal  = rowTotal            # must be same as rowTotal
    widthLine = 2.0                 # should be divisible by 2
    sizeCell  = GRID_SIZE / GLfloat(rowTotal)
    zOffset   = -40.0

  var xl, xr, yt, yb: GLfloat

  glPushMatrix()
  glDisable(GL_CULL_FACE)

  # Another relative Z translation to separate objects.
  glTranslatef(0, 0, DIST_BALL)

  # Draw vertical lines (as skinny 3D rectangles).
  for col in 0..colTotal:
    # Compute co-ords of line.
    xl = -GRID_SIZE / 2 + GLfloat(col) * sizeCell
    xr = xl + widthLine

    yt =  GRID_SIZE / 2
    yb = -GRID_SIZE / 2 - widthLine

    glBegin(GL_POLYGON)

    glColor3f(0.6, 0.1, 0.6)        # purple

    glVertex3f(xr, yt, zOffset)     # NE
    glVertex3f(xl, yt, zOffset)     # NW
    glVertex3f(xl, yb, zOffset)     # SW
    glVertex3f(xr, yb, zOffset)     # SE

    glEnd()

  # Draw horizontal lines (as skinny 3D rectangles).
  for row in 0..rowTotal:
    # Compute co-ords of line.
    yt = GRID_SIZE / 2 - GLfloat(row) * sizeCell
    yb = yt - widthLine

    xl = -GRID_SIZE / 2
    xr =  GRID_SIZE / 2 + widthLine

    glBegin(GL_POLYGON)

    glColor3f(0.6, 0.1, 0.6)        # purple

    glVertex3f(xr, yt, zOffset)     # NE
    glVertex3f(xl, yt, zOffset)     # NW
    glVertex3f(xl, yb, zOffset)     # SW
    glVertex3f(xr, yb, zOffset)     # SE

    glEnd()

  glPopMatrix()


#======================================================================
# main
#======================================================================
proc main() =
  randomize()

  glfw.initialize()

  var cfg = DefaultOpenglWindowConfig
  cfg.size = (w: 400, h: 400)
  cfg.title = "Boing (classic Amiga demo)"
  cfg.resizable = true
  cfg.version = glv20

  let win = newWindow(cfg)

  win.setAspectRatio(1, 1)

  win.framebufferSizeCb = reshape
  win.keyCb = keyCb
  win.mouseButtonCb = mouseButtonCb
  win.cursorPositionCb = cursorPosCb

  if not gladLoadGL(getProcAddress):
    quit "Error initialising OpenGL"

  glfw.swapInterval(1)

  (width, height) = framebufferSize(win)
  win.reshape((width, height))

  setTime(0)

  init()

  #* Main loop
  while true:
    # Timing
    t = getTime()
    dt = t - tOld
    tOld = t

    # Draw one frame
    display()

    # Swap buffers
    glfw.swapBuffers(win)
    glfw.pollEvents()

    # Check if we are still running
    if glfw.shouldClose(win):
      break

  glfw.terminate()


main()
