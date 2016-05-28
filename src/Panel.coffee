class Panel
  constructor: (@_stepCount) ->
    @_activeStep = -1

    @_cells = Object.create null

    @_lines = [
      [ [ 0, 0 ], [ 16, 16 ] ]
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

  _tryAddDraft: ->
    # non-positive length check
    if @_draftLine[0][0] >= @_draftLine[1][0]
      return

    # zero source length check
    if @_draftLine[0][1] is @_draftLine[1][1]
      return

    # start overlap check
    for line in @_lines
      if @_draftLine[0][0] is line[0][0] and @_draftLine[0][1] is line[0][1]
        return

    @_lines.push [ @_draftLine[0], @_draftLine[1] ]

  startLine: (plane, planeGesture) ->
    cell = @_convertPlane(plane)

    if cell[0] >= 0 and cell[0] <= @_stepCount and cell[1] >= 0 and cell[1] <= @_stepCount
      @_draftLine = [ cell, cell ]

      planeGesture.on 'move', (movePlane) =>
        moveCell = @_convertPlane(movePlane)

        dx = moveCell[0] - @_draftLine[0][0]
        dy = moveCell[1] - @_draftLine[0][1]

        len = Math.round((dx + dy) / 2)
        len = Math.min(len, Math.min(@_stepCount - @_draftLine[0][0], @_stepCount - @_draftLine[0][1]))
        len = Math.max(len, Math.max(-@_draftLine[0][0], -@_draftLine[0][1]))

        moveCell[0] = @_draftLine[0][0] + len
        moveCell[1] = @_draftLine[0][1] + len

        @_draftLine[1] = moveCell

      planeGesture.on 'end', =>
        @_tryAddDraft()
        @_draftLine = null

module.exports = Panel
