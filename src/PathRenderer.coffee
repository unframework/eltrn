vec3 = require('gl-matrix').vec3
vec4 = require('gl-matrix').vec4
mat4 = require('gl-matrix').mat4

FlatShader = require('./FlatShader.coffee')

module.exports = class PathRenderer
  constructor: (@_gl) ->
    @_flatShader = new FlatShader @_gl

    @_meshBuffer = @_gl.createBuffer()
    @_gl.bindBuffer @_gl.ARRAY_BUFFER, @_meshBuffer
    @_gl.bufferData @_gl.ARRAY_BUFFER, new Float32Array([
      0, -0.05
      1, -0.05
      0, 0.05
      0, 0.05
      1, -0.05
      1, 0.05
    ]), @_gl.STATIC_DRAW

    @_modelPosition = vec3.create()
    @_modelScale = vec3.fromValues(1, 1, 1)
    @_modelMatrix = mat4.create()

    @_blackColor = vec4.fromValues(0, 0, 0, 1)

  draw: (cameraMatrix, pathCb) ->
    # general setup
    @_flatShader.bind()

    @_gl.uniformMatrix4fv @_flatShader.cameraLocation, false, cameraMatrix

    @_gl.bindBuffer @_gl.ARRAY_BUFFER, @_meshBuffer
    @_gl.vertexAttribPointer @_flatShader.positionLocation, 2, @_gl.FLOAT, false, 0, 0

    # body
    isStart = true
    lastX = null
    lastY = null

    pathCb((x, y) =>
      if isStart
        isStart = false
      else
        len = Math.hypot(y - lastY, x - lastX)
        angle = Math.atan2(y - lastY, x - lastX)

        vec3.set(@_modelPosition, lastX, lastY, 0.01)
        @_modelScale[0] = len

        mat4.identity(@_modelMatrix)
        mat4.translate(@_modelMatrix, @_modelMatrix, @_modelPosition)
        mat4.rotateZ(@_modelMatrix, @_modelMatrix, angle)
        mat4.scale(@_modelMatrix, @_modelMatrix, @_modelScale)

        @_gl.uniform4fv @_flatShader.colorLocation, @_blackColor
        @_gl.uniformMatrix4fv @_flatShader.modelLocation, false, @_modelMatrix

        @_gl.drawArrays @_gl.TRIANGLES, 0, 2 * 3

      lastX = x
      lastY = y
    )
