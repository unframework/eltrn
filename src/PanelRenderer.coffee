vec3 = require('gl-matrix').vec3
vec4 = require('gl-matrix').vec4
mat4 = require('gl-matrix').mat4

FlatShader = require('./FlatShader.coffee')

module.exports = class PanelRenderer
  constructor: (@_gl) ->
    @_flatShader = new FlatShader @_gl

    @_meshBuffer = @_gl.createBuffer()
    @_gl.bindBuffer @_gl.ARRAY_BUFFER, @_meshBuffer
    @_gl.bufferData @_gl.ARRAY_BUFFER, new Float32Array([
      -0.5, -0.5
      0.5, -0.5
      -0.5, 0.5
      -0.5, 0.5
      0.5, -0.5
      0.5, 0.5
    ]), @_gl.STATIC_DRAW

    @_modelPosition = vec3.create()
    @_modelMatrix = mat4.create()

    @_panelColor = vec4.fromValues(0, 0, 0, 1)

  draw: (cameraMatrix) ->
    # general setup
    @_flatShader.bind()

    @_gl.uniformMatrix4fv @_flatShader.cameraLocation, false, cameraMatrix

    @_gl.bindBuffer @_gl.ARRAY_BUFFER, @_meshBuffer
    @_gl.vertexAttribPointer @_flatShader.positionLocation, 2, @_gl.FLOAT, false, 0, 0

    # body
    mat4.identity(@_modelMatrix)
    mat4.translate(@_modelMatrix, @_modelMatrix, @_modelPosition)

    @_gl.uniform4fv @_flatShader.colorLocation, @_panelColor
    @_gl.uniformMatrix4fv @_flatShader.modelLocation, false, @_modelMatrix

    @_gl.drawArrays @_gl.TRIANGLES, 0, 2 * 3
