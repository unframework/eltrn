class Panel
  constructor: (@_stepCount) ->
    @_activeStep = -1
    @_selections = Object.create null

    for i in [0 ... @_stepCount]
      @_selections["#{i}x#{i}"] = true

    @_draftLine = null

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

      @_draftLine = [ cell, cell ]

      planeGesture.on 'move', (movePlane) =>
        moveCell = @_convertPlane(movePlane)

        if @_cellIsInBounds moveCell
          @_draftLine[1] = moveCell

      planeGesture.on 'end', =>
        @_draftLine = null

  toggleCell: (col, row) ->
    coord = "#{col}x#{row}"
    @_selections[coord] = !@_selections[coord]

module.exports = Panel
