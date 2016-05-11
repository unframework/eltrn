STEP_COUNT = 16

class UI
  constructor: ->
    @_selections = Object.create null
    @_selections['3x4'] = true

  render: (h) ->
    h 'div', (for row in [0 ... STEP_COUNT]
      h 'div', (for col in [0 ... STEP_COUNT]
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
