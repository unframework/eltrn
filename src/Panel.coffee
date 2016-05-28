class Panel
  constructor: (@_stepCount) ->
    @_activeStep = -1

    @_cells = Object.create null

    @_draft = null

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

          if !@_cells[coord]
            break

          stepCount += 1
          continuations[coord] = true

        if stepCount > 0
          stepList.push [ parseInt(col, 10) / @_stepCount, parseInt(row, 10) / @_stepCount, stepCount / @_stepCount ]

    stepList

  isCellOn: (col, row) ->
    coord = "#{col}x#{row}"
    !!@_cells[coord]

  isCellDraft: (col, row) ->
    if @_draft
      dx = col - @_draft[0][0]
      dy = row - @_draft[0][1]

      dx is dy and dx >= @_draft[1] and dx <= @_draft[2]

  setActiveStep: (index) ->
    @_activeStep = index

  _convertPlane: (plane) ->
    cellCol = Math.floor(plane[0] + @_stepCount * 0.5)
    cellRow = Math.floor(plane[1] + @_stepCount * 0.5)

    [ cellCol, cellRow ]

  _tryAddDraft: ->
    [ x, y ] = @_draft[0]
    below = @_draft[1]
    above = @_draft[2]

    newValue = !@_cells["#{x}x#{y}"]

    while below < 0
      @_cells["#{x + below}x#{y + below}"] = newValue
      below += 1

    while above > 0
      @_cells["#{x + above}x#{y + above}"] = newValue
      above -= 1

    @_cells["#{x}x#{y}"] = newValue

  startLine: (plane, planeGesture) ->
    cell = @_convertPlane(plane)

    if cell[0] >= 0 and cell[0] <= @_stepCount and cell[1] >= 0 and cell[1] <= @_stepCount
      @_draft = [ cell, 0, 0 ]

      planeGesture.on 'move', (movePlane) =>
        moveCell = @_convertPlane(movePlane)

        dx = moveCell[0] - @_draft[0][0]
        dy = moveCell[1] - @_draft[0][1]

        len = Math.round((dx + dy) / 2)
        len = Math.min(len, Math.min(@_stepCount - @_draft[0][0], @_stepCount - @_draft[0][1]))
        len = Math.max(len, Math.max(-@_draft[0][0], -@_draft[0][1]))

        @_draft[1] = Math.min(len, 0)
        @_draft[2] = Math.max(0, len)

      planeGesture.on 'end', =>
        @_tryAddDraft()
        @_draft = null

module.exports = Panel
