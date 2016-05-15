class Panel
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

  isCellOn: (col, row) ->
    coord = "#{col}x#{row}"
    !!@_selections[coord]

  setActiveStep: (index) ->
    @_activeStep = index

  _convertPlane: (plane) ->
    cellCol = Math.floor(plane[0] + @_stepCount * 0.5)
    cellRow = Math.floor(plane[1] + @_stepCount * 0.5)

    [ cellCol, cellRow ]

  startLine: (plane, planeGesture) ->
    [ cellCol, cellRow ] = @_convertPlane(plane)

    if cellCol >= 0 and cellCol < @_stepCount and cellRow >= 0 and cellRow < @_stepCount
      @toggleCell cellCol, cellRow

      planeGesture.on 'move', (movePlane) =>
        [ moveCellCol, moveCellRow ] = @_convertPlane(movePlane)

        # first, debounce
        if moveCellCol isnt cellCol or moveCellRow isnt cellRow
          cellCol = moveCellCol
          cellRow = moveCellRow

          if moveCellCol >= 0 and moveCellCol < @_stepCount and moveCellRow >= 0 and moveCellRow < @_stepCount
            @toggleCell moveCellCol, moveCellRow

  toggleCell: (col, row) ->
    coord = "#{col}x#{row}"
    @_selections[coord] = !@_selections[coord]

module.exports = Panel
