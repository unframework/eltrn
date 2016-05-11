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
    h 'div', (for row in [0 ... @_stepCount]
      h 'div', (for col in [0 ... @_stepCount]
        isActiveStep = @_activeStep is col

        do =>
          coord = "#{col}x#{row}"

          h 'button', {
            style: {
              display: 'inline-block'
              width: '32px'
              height: '32px'
              background: if @_selections[coord]
                '#486'
              else if isActiveStep
                '#888'
              else (if (Math.floor(col / 4) + Math.floor(row / 4)) % 2 then '#aaa' else '#bbb')
            }
            onclick: =>
              @_selections[coord] = !@_selections[coord]
          }
      )
    )

module.exports = UI
