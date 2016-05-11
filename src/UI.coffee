class UI
  constructor: (@_stepCount) ->
    @_activeStep = -1
    @_selections = Object.create null
    @_selections['3x4'] = true

  getSteps: ->
    for coord, value of @_selections when value
      [col, row] = coord.split 'x'
      [ parseInt(col, 10) / @_stepCount, parseInt(row, 10) / @_stepCount ]

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
