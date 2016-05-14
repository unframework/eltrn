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

    @_panelColor = vec4.fromValues(0.8, 0.8, 0.8, 1)

  draw: (cameraMatrix, stepCount) ->
    # general setup
    @_flatShader.bind()

    @_gl.uniformMatrix4fv @_flatShader.cameraLocation, false, cameraMatrix

    @_gl.bindBuffer @_gl.ARRAY_BUFFER, @_meshBuffer
    @_gl.vertexAttribPointer @_flatShader.positionLocation, 2, @_gl.FLOAT, false, 0, 0

    # body
    @_gl.uniform4fv @_flatShader.colorLocation, @_panelColor

    rowPos = vec3.fromValues(0, 0, 0)
    cellScale = vec3.fromValues(0.9, 0.9, 0.9)

    for row in [0 ... stepCount]
      for col in [0 ... stepCount]
        rowPos[0] = col - (stepCount - 1) * 0.5
        rowPos[1] = row - (stepCount - 1) * 0.5

        mat4.identity(@_modelMatrix)
        mat4.translate(@_modelMatrix, @_modelMatrix, rowPos)
        mat4.scale(@_modelMatrix, @_modelMatrix, cellScale)

        @_gl.uniformMatrix4fv @_flatShader.modelLocation, false, @_modelMatrix
        @_gl.drawArrays @_gl.TRIANGLES, 0, 2 * 3
