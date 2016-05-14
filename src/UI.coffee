
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
    new GLWidget 32 * 16, 32 * 16, (gl) =>
      console.log 'GL init!'
    , () =>

module.exports = UI
