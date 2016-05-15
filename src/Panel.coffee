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

  _cellIsInBounds: (cell) ->
    cell[0] >= 0 and cell[0] < @_stepCount and cell[1] >= 0 and cell[1] < @_stepCount

  startLine: (plane, planeGesture) ->
    cell = @_convertPlane(plane)

    if @_cellIsInBounds cell
      @toggleCell cell[0], cell[1]

      planeGesture.on 'move', (movePlane) =>
        moveCell = @_convertPlane(movePlane)

        # first, debounce
        if moveCell[0] isnt cell[0] or moveCell[1] isnt cell[1]
          cell[0] = moveCell[0]
          cell[1] = moveCell[1]

          if moveCell[0] >= 0 and moveCell[0] < @_stepCount and moveCell[1] >= 0 and moveCell[1] < @_stepCount
            @toggleCell moveCell[0], moveCell[1]

  toggleCell: (col, row) ->
    coord = "#{col}x#{row}"
    @_selections[coord] = !@_selections[coord]

module.exports = Panel
