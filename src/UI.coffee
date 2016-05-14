vec3 = require('gl-matrix').vec3
vec4 = require('gl-matrix').vec4
mat4 = require('gl-matrix').mat4

PanelRenderer = require('./PanelRenderer.coffee')

createCanvas = (w, h) ->
  viewCanvas = document.createElement('canvas')
  viewCanvas.width = w or window.innerWidth
  viewCanvas.height = h or window.innerHeight

  viewCanvas

class GLWidget
  constructor: (@_w, @_h, @_onInit, @_onUpdate) ->

  type: 'Widget'
  init: () ->
    canvas = createCanvas @_w, @_h
    @_onInit canvas.getContext('experimental-webgl')

    canvas

  update: () ->
    @_onUpdate()

class UI
  constructor: (@_stepCount) ->
    @_activeStep = -1
    @_selections = Object.create null

    @_cameraPosition = vec3.create()
    vec3.set @_cameraPosition, 0, 0, -8

    @_panelRenderer = null

    for i in [0 ... @_stepCount]
      @_selections["#{i}x#{i}"] = true

  getSteps: ->
    continuations = Object.create null

    stepList = []

    # walk column-first and find continuous stretches
    for col in [0 ... @_stepCount]
      for row in [0 ... @_stepCount]
        if continuations["#{col}x#{row}"]
          continue

        stepCount = 0
        maxStepLength = Math.min(@_stepCount - col, @_stepCount - row)

        for i in [0 ... maxStepLength]
          coord = "#{col + i}x#{row + i}"

          if !@_selections[coord]
            break

          stepCount += 1
          continuations[coord] = true

        if stepCount > 0
          stepList.push [ parseInt(col, 10) / @_stepCount, parseInt(row, 10) / @_stepCount, stepCount ]

    stepList

  setActiveStep: (index) ->
    @_activeStep = index

  render: (h) ->
    w = 800
    h = 600

    new GLWidget w, h, (gl) =>
      console.log 'GL init!'
      @_panelRenderer = new PanelRenderer(gl)
    , () =>
      cameraTransform = mat4.create()
      mat4.perspective cameraTransform, 45, w / h, 1, 20
      mat4.rotateX cameraTransform, cameraTransform, -0.3
      mat4.translate cameraTransform, cameraTransform, @_cameraPosition

      @_panelRenderer.draw(cameraTransform)

module.exports = UI
