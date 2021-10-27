#------------------------------------------------------------------------
# Nim port of the GLFW example 'gears.c'
# https://github.com/glfw/glfw/blob/master/examples/gears.c
#
# Ported by John Novak <john@johnnovak.net>
#
# Requires nim-glm.
#------------------------------------------------------------------------

#
# 3-D gear wheels.  This program is in the public domain.
#
# Command line options:
#    -info      print GL implementation information
#    -exit      automatically exit after 30 seconds
#
#
# Brian Paul
#
#
# Marcus Geelnard:
#   - Conversion to GLFW
#   - Time based rendering (frame rate independent)
#   - Slightly modified camera that should work better for stereo viewing
#
#
# Camilla Berglund:
#   - Removed FPS counter (this is not a benchmark)
#   - Added a few comments
#   - Enabled vsync
#

import math

import glad/gl
import glm
import glfw

#  Draw a gear wheel.  You'll probably want to call this function when
#  building a display list since we do a lot of trig here.
#
#  Input:  innerRadius - radius of hole at center
#          outerRadius - radius at center of teeth
#          width       - width of gear
#          teeth       - number of teeth
#          toothDepth  - depth of tooth
#
proc gear(innerRadius, outerRadius, width: GLfloat,
          teeth: int, toothDepth: GLfloat) =

  proc calcAngle(i: int): GLfloat =
    GLfloat(i) * 2 * PI / GLfloat(teeth)

  let
    r0 = innerRadius
    r1 = outerRadius - toothDepth / 2
    r2 = outerRadius + toothDepth / 2
    da = 2 * PI / float(teeth) / 4

  var
    angle, u, v, length: GLfloat

  glShadeModel(GL_FLAT)

  glNormal3f(0.0, 0.0, 1.0)

  # draw front face
  glBegin(GL_QUAD_STRIP)

  for i in 0..teeth:
    angle = calcAngle(i)

    glVertex3f(r0 * cos(angle), r0 * sin(angle), width * 0.5)
    glVertex3f(r1 * cos(angle), r1 * sin(angle), width * 0.5)

    if i < teeth:
      glVertex3f(r0 * cos(angle), r0 * sin(angle), width * 0.5)
      glVertex3f(r1 * cos(angle + 3 * da), r1 * sin(angle + 3 * da),width * 0.5)

  glEnd()

  # draw front sides of teeth
  glBegin(GL_QUADS)

  for i in 0..teeth-1:
    angle = calcAngle(i)

    glVertex3f(r1 * cos(angle), r1 * sin(angle), width * 0.5)
    glVertex3f(r2 * cos(angle + da), r2 * sin(angle + da), width * 0.5)
    glVertex3f(r2 * cos(angle + 2 * da), r2 * sin(angle + 2 * da), width * 0.5)
    glVertex3f(r1 * cos(angle + 3 * da), r1 * sin(angle + 3 * da), width * 0.5)

  glEnd()

  glNormal3f(0.0, 0.0, -1.0)

  # draw back face
  glBegin(GL_QUAD_STRIP)

  for i in 0..teeth:
    angle = calcAngle(i)

    glVertex3f(r1 * cos(angle), r1 * sin(angle), -width * 0.5)
    glVertex3f(r0 * cos(angle), r0 * sin(angle), -width * 0.5)

    if i < teeth:
      glVertex3f(r1 * cos(angle + 3 * da),
                 r1 * sin(angle + 3 * da), -width * 0.50)
      glVertex3f(r0 * cos(angle), r0 * sin(angle), -width * 0.5)

  glEnd()

  # draw back sides of teeth
  glBegin(GL_QUADS)

  for i in 0..teeth-1:
    angle = calcAngle(i)

    glVertex3f(r1 * cos(angle + 3 * da), r1 * sin(angle + 3 * da), -width * 0.5)
    glVertex3f(r2 * cos(angle + 2 * da), r2 * sin(angle + 2 * da), -width * 0.5)
    glVertex3f(r2 * cos(angle + da), r2 * sin(angle + da), -width * 0.5)
    glVertex3f(r1 * cos(angle), r1 * sin(angle), -width * 0.5)

  glEnd()

  # draw outward faces of teeth
  glBegin(GL_QUAD_STRIP)

  for i in 0..teeth-1:
    angle = calcAngle(i)

    glVertex3f(r1 * cos(angle), r1 * sin(angle), width * 0.5)
    glVertex3f(r1 * cos(angle), r1 * sin(angle), -width * 0.5)

    u = r2 * cos(angle + da) - r1 * cos(angle)
    v = r2 * sin(angle + da) - r1 * sin(angle)
    length = sqrt(u * u + v * v)

    u /= length
    v /= length

    glNormal3f(v, -u, 0.0)
    glVertex3f(r2 * cos(angle + da), r2 * sin(angle + da), width * 0.5)
    glVertex3f(r2 * cos(angle + da), r2 * sin(angle + da), -width * 0.5)
    glNormal3f(cos(angle), sin(angle), 0.0)
    glVertex3f(r2 * cos(angle + 2 * da), r2 * sin(angle + 2 * da), width * 0.5)
    glVertex3f(r2 * cos(angle + 2 * da), r2 * sin(angle + 2 * da), -width * 0.5)

    u = r1 * cos(angle + 3 * da) - r2 * cos(angle + 2 * da)
    v = r1 * sin(angle + 3 * da) - r2 * sin(angle + 2 * da)

    glNormal3f(v, -u, 0.0)
    glVertex3f(r1 * cos(angle + 3 * da), r1 * sin(angle + 3 * da), width * 0.5)
    glVertex3f(r1 * cos(angle + 3 * da), r1 * sin(angle + 3 * da), -width * 0.5)
    glNormal3f(cos(angle), sin(angle), 0.0)

  glVertex3f(r1 * cos(0.0), r1 * sin(0.0), width * 0.5)
  glVertex3f(r1 * cos(0.0), r1 * sin(0.0), -width * 0.5)

  glEnd()

  glShadeModel(GL_SMOOTH)

  # draw inside radius cylinder
  glBegin(GL_QUAD_STRIP)

  for i in 0..teeth:
    angle = calcAngle(i)

    glNormal3f(-cos(angle), -sin(angle), 0.0)
    glVertex3f(r0 * cos(angle), r0 * sin(angle), -width * 0.5)
    glVertex3f(r0 * cos(angle), r0 * sin(angle), width * 0.5)

  glEnd()


# OpenGL draw function & timing
var
  viewRotX = 20.0
  viewRotY = 30.0
  viewRotZ = 0.0
  angle    = 0.0
  gear1, gear2, gear3: GLuint


proc draw() =
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

  glPushMatrix()

  glRotatef(viewRotX, 1.0, 0.0, 0.0)
  glRotatef(viewRotY, 0.0, 1.0, 0.0)
  glRotatef(viewRotZ, 0.0, 0.0, 1.0)

  glPushMatrix()
  glTranslatef(-3.0, -2.0, 0.0)
  glRotatef(angle, 0.0, 0.0, 1.0)
  glCallList(gear1)
  glPopMatrix()

  glPushMatrix()
  glTranslatef(3.1, -2.0, 0.0)
  glRotatef(-2.0 * angle - 9.0, 0.0, 0.0, 1.0)
  glCallList(gear2)
  glPopMatrix()

  glPushMatrix()
  glTranslatef(-3.1, 4.2, 0.0)
  glRotatef(-2.0 * angle - 25.0, 0.0, 0.0, 1.0)
  glCallList(gear3)
  glPopMatrix()

  glPopMatrix()


# update animation parameters
proc animate() = angle = 100.0 * getTime()


# change view angle, exit upon ESC
proc keyCb(win: Window, key: Key, scanCode: int32, action: KeyAction,
           modKeys: set[ModifierKey]) =

  if action != kaDown: return

  case key
  of keyZ:      viewRotZ += (if modKeys == {mkShift}: -5.0 else: 5.0)
  of keyEscape: win.shouldClose = true
  of keyUp:     viewRotX += 5.0
  of keyDown:   viewRotX -= 5.0
  of keyLeft:   viewRotY += 5.0
  of keyRight:  viewRotY -= 5.0
  else:         return


# new window size
proc reshape(win: Window, res: tuple[w, h: int32]) =
  let
    h = res.h / res.w
    zNear = 5.0
    zFar  = 30.0
    xMax  = zNear * 0.5

  glViewport(0, 0, GLint(res.w), GLint(res.h))
  glMatrixMode(GL_PROJECTION)
  glLoadIdentity()
  glFrustum(-xMax, xMax, -xMax * h, xMax * h, zNear, zFar)
  glMatrixMode(GL_MODELVIEW)
  glLoadIdentity()
  glTranslatef(0.0, 0.0, -20.0)


# program & OpenGL initialization
proc init() =
  var
    pos   = vec4[GLfloat](5.0, 5.0, 10.0, 0.0)
    red   = vec4[GLfloat](0.8, 0.1,  0.0, 1.0)
    green = vec4[GLfloat](0.0, 0.8,  0.2, 1.0)
    blue  = vec4[GLfloat](0.2, 0.2,  1.0, 1.0)

  glLightfv(GL_LIGHT0, GL_POSITION, pos.caddr)
  glEnable(GL_CULL_FACE)
  glEnable(GL_LIGHTING)
  glEnable(GL_LIGHT0)
  glEnable(GL_DEPTH_TEST)

  # make the gears
  gear1 = glGenLists(1)
  glNewList(gear1, GL_COMPILE)
  glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, red.caddr)
  gear(1.0, 4.0, 1.0, 20, 0.7)
  glEndList()

  gear2 = glGenLists(1)
  glNewList(gear2, GL_COMPILE)
  glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, green.caddr)
  gear(0.5, 2.0, 2.0, 10, 0.7)
  glEndList()

  gear3 = glGenLists(1)
  glNewList(gear3, GL_COMPILE)
  glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, blue.caddr)
  gear(1.3, 2.0, 0.5, 10, 0.7)
  glEndList()

  glEnable(GL_NORMALIZE)


proc main() =
  glfw.initialize()

  var cfg = DefaultOpenglWindowConfig
  cfg.size = (w: 300, h: 300)
  cfg.title = "Gears"
  cfg.resizable = true
  cfg.bits = (r: 8, g: 8, b: 8, a: 8, stencil: 8, depth: 16)
  cfg.transparentFramebuffer = true
  cfg.version = glv20
  var win = newWindow(cfg)

  # Set callback functions
  win.framebufferSizeCb = reshape
  win.keyCb = keyCb

  if not gladLoadGL(getProcAddress):
    quit "Error initialising OpenGL"

  glfw.swapInterval(1)

  var width, height: int
  (width, height) = framebufferSize(win)
  win.reshape((width, height))

  init()

  while not win.shouldClose:
    draw()
    animate()

    glfw.swapBuffers(win)
    glfw.pollEvents()

  glfw.terminate()


main()
