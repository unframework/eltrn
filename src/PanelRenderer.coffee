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

    @_panelCellColor = vec4.fromValues(0.8, 0.8, 0.8, 1)
    @_activeCellColor = vec4.fromValues(0.7, 0.9, 0.7, 1)
    @_onCellColor = vec4.fromValues(0.9, 0.6, 0.6, 1)

  draw: (cameraMatrix, panel) ->
    # general setup
    @_flatShader.bind()

    @_gl.uniformMatrix4fv @_flatShader.cameraLocation, false, cameraMatrix

    @_gl.bindBuffer @_gl.ARRAY_BUFFER, @_meshBuffer
    @_gl.vertexAttribPointer @_flatShader.positionLocation, 2, @_gl.FLOAT, false, 0, 0

    # body
    rowPos = vec3.fromValues(0, 0, 0)
    cellScale = vec3.fromValues(0.9, 0.9, 0.9)

    for row in [0 ... panel._stepCount]
      for col in [0 ... panel._stepCount]
        isActive = col is panel._activeStep
        isOn = panel.isCellOn(col, row)
        @_gl.uniform4fv @_flatShader.colorLocation, if isOn
          @_onCellColor
        else if isActive
          @_activeCellColor
        else
          @_panelCellColor

        rowPos[0] = col - (panel._stepCount - 1) * 0.5
        rowPos[1] = row - (panel._stepCount - 1) * 0.5

        mat4.identity(@_modelMatrix)
        mat4.translate(@_modelMatrix, @_modelMatrix, rowPos)
        mat4.scale(@_modelMatrix, @_modelMatrix, cellScale)

        @_gl.uniformMatrix4fv @_flatShader.modelLocation, false, @_modelMatrix
        @_gl.drawArrays @_gl.TRIANGLES, 0, 2 * 3

  click: (rayStart, rayEnd) ->
    console.log rayStart[0], rayStart[1], rayStart[2]
    console.log rayEnd[0], rayEnd[1], rayEnd[2]

    normal = vec3.fromValues(0, 0, 1)

    kStart = vec3.dot normal, rayStart
    kEnd = vec3.dot normal, rayEnd

    planeX = rayStart[0] + (-kStart) * (rayEnd[0] - rayStart[0]) / (kEnd - kStart)
    planeY = rayStart[1] + (-kStart) * (rayEnd[1] - rayStart[1]) / (kEnd - kStart)
