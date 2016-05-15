class Panel
  constructor: (@_stepCount) ->
    @_activeStep = -1

    @_lines = [
      [ [ 0, 0 ], [ 16, 8 ] ]
    ]

    @_draftLine = null

  getSteps: ->
    [
      line[0][0] / @_stepCount
      line[0][1] / @_stepCount
      (line[1][0] - line[0][0]) / @_stepCount
      (line[1][1] - line[0][1]) / @_stepCount
    ] for line in @_lines

  setActiveStep: (index) ->
    @_activeStep = index

  _convertPlane: (plane) ->
    cellCol = Math.round(plane[0] + @_stepCount * 0.5)
    cellRow = Math.round(plane[1] + @_stepCount * 0.5)

    [ cellCol, cellRow ]

  _cellIsInBounds: (cell) ->
    cell[0] >= 0 and cell[0] < @_stepCount and cell[1] >= 0 and cell[1] < @_stepCount

  startLine: (plane, planeGesture) ->
    cell = @_convertPlane(plane)

    if @_cellIsInBounds cell
      @_draftLine = [ cell, cell ]

      planeGesture.on 'move', (movePlane) =>
        moveCell = @_convertPlane(movePlane)

        if @_cellIsInBounds moveCell
          @_draftLine[1] = moveCell

      planeGesture.on 'end', =>
        @_draftLine = null

module.exports = Panel
