#------------------------------------------------------------------------
# Nim port of the GLFW example 'simple.c'
# https://github.com/glfw/glfw/blob/master/examples/simple.c
#
# Ported by John Novak <john@johnnovak.net>
#
# Requires nim-glm.
#------------------------------------------------------------------------

#========================================================================
# OpenGL triangle example
# Copyright (c) Camilla Löwy <elmindreda@glfw.org>
#
# This software is provided 'as-is', without any express or implied
# warranty. In no event will the authors be held liable for any damages
# arising from the use of this software.
#
# Permission is granted to anyone to use this software for any purpose,
# including commercial applications, and to alter it and redistribute it
# freely, subject to the following restrictions:
#
# 1. The origin of this software must not be misrepresented; you must not
#    claim that you wrote the original software. If you use this software
#    in a product, an acknowledgment in the product documentation would
#    be appreciated but is not required.
#
# 2. Altered source versions must be plainly marked as such, and must not
#    be misrepresented as being the original software.
#
# 3. This notice may not be removed or altered from any source
#    distribution.
#
#========================================================================

import glad/gl
import glm
import glfw

type
  Vertex = object
    x, y: GLfloat
    r, g, b: GLfloat

var vertices: array[0..2, Vertex] =
  [ Vertex(x: -0.6, y: -0.4, r: 1.0, g: 0.0, b: 0.0),
    Vertex(x:  0.6, y: -0.4, r: 0.0, g: 1.0, b: 0.0),
    Vertex(x:  0.0, y:  0.6, r: 0.0, g: 0.0, b: 1.0) ]

let vertexShaderText = """
#version 330
uniform mat4 MVP;
in vec3 vCol;
in vec2 vPos;
out vec3 color;

void main()
{
  gl_Position = MVP * vec4(vPos, 0.0, 1.0);
  color = vCol;
}
"""

let fragmentShaderText = """
#version 330
in vec3 color;
out vec4 fragment;

void main()
{
  fragment = vec4(color, 1.0);
}
"""

var
  program: GLuint
  mvpLocation: GLuint
  vertexArray: GLuint


proc keyCb(win: Window, key: Key, scanCode: int32, action: KeyAction,
           modKeys: set[ModifierKey]) =

  if key == keyEscape and action == kaDown:
    win.shouldClose = true


proc init() =
  var vertexBuffer: GLuint
  glGenBuffers(1, vertexBuffer.addr)
  glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer)

  glBufferData(GL_ARRAY_BUFFER, GLsizeiptr(sizeof(vertices)), vertices.addr,
               GL_STATIC_DRAW)

  var vertexShader = glCreateShader(GL_VERTEX_SHADER)
  var vertexShaderTextArr = [cstring(vertexShaderText)]
  glShaderSource(vertexShader, GLsizei(1),
                 cast[cstringArray](vertexShaderTextArr.addr), nil)
  glCompileShader(vertexShader)

  var fragmentShaderTextArr = [cstring(fragmentShaderText)]
  var fragmentShader = glCreateShader(GL_FRAGMENT_SHADER)
  glShaderSource(fragmentShader, 1,
                 cast[cstringArray](fragmentShaderTextArr.addr), nil)
  glCompileShader(fragmentShader)

  program = glCreateProgram()
  glAttachShader(program, vertexShader)
  glAttachShader(program, fragmentShader)
  glLinkProgram(program)

  mvpLocation = cast[GLuint](glGetUniformLocation(program, "MVP"))
  var vposLocation = cast[GLuint](glGetAttribLocation(program, "vPos"))
  var vcolLocation = cast[GLuint](glGetAttribLocation(program, "vCol"))

  glGenVertexArrays(1, vertexArray.addr);
  glBindVertexArray(vertexArray);
  glEnableVertexAttribArray(vposLocation);
  glVertexAttribPointer(vposLocation, 2, cGL_FLOAT, false,
                        GLsizei(sizeof(Vertex)), cast[pointer](0))

  glEnableVertexAttribArray(vcolLocation)
  glVertexAttribPointer(vcolLocation, 3, cGL_FLOAT, false,
                        GLsizei(sizeof(Vertex)),
                        cast[pointer](sizeof(GLfloat) * 2));


proc draw(win: Window) =
  let normal = vec3[GLfloat](0.0, 0.0, 1.0)

  var width, height: int
  (width, height) = glfw.framebufferSize(win)

  var ratio = width / height

  glViewport(0, 0, GLsizei(width), GLsizei(height))
  glClear(GL_COLOR_BUFFER_BIT)

  var m = mat4x4[GLfloat](vec4(1'f32, 0'f32, 0'f32, 0'f32),
                          vec4(0'f32, 1'f32, 0'f32, 0'f32),
                          vec4(0'f32, 0'f32, 1'f32, 0'f32),
                          vec4(0'f32, 0'f32, 0'f32, 1'f32))
  m = m.rotate(getTime(), normal)
  var p = ortho[GLfloat](-ratio, ratio, -1.0, 1.0, 1.0, -1.0)
  var mvp = p * m

  glUseProgram(program)
  glUniformMatrix4fv(GLint(mvpLocation), 1, false, mvp.caddr);
  glBindVertexArray(vertexArray)
  glDrawArrays(GL_TRIANGLES, 0, 3)


proc main() =
  glfw.initialize()

  var cfg = DefaultOpenglWindowConfig
  cfg.size = (w: 640, h: 480)
  cfg.title = "Simple example"
  cfg.resizable = true
  cfg.version = glv33
  cfg.forwardCompat = true
  cfg.profile = opCoreProfile

  var win = newWindow(cfg)

  win.keyCb = keyCb

  let c = createStandardCursor(csResizeNESW)
  win.cursor = c

  if not gladLoadGL(getProcAddress):
    quit "Error initialising OpenGL"

  glfw.swapInterval(1)

  init()

  while not win.shouldClose:
    draw(win)

    glfw.swapBuffers(win)
    glfw.pollEvents()

  glfw.terminate()


main()
