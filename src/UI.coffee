class UI
  constructor: (@_stepCount) ->
    @_selections = Object.create null
    @_selections['3x4'] = true

  getSteps: ->
    for coord in Object.keys @_selections
      [col, row] = coord.split 'x'
      [ parseInt(col, 10) / @_stepCount, parseInt(row, 10) / @_stepCount ]

  render: (h) ->
    h 'div', (for row in [0 ... @_stepCount]
      h 'div', (for col in [0 ... @_stepCount]
        do =>
          coord = "#{col}x#{row}"

          h 'button', {
            style: {
              display: 'inline-block'
              width: '32px'
              height: '32px'
              background: if @_selections[coord] then '#486' else '#aaa'
            }
            onclick: =>
              @_selections[coord] = !@_selections[coord]
          }
      )
    )

module.exports = UI
