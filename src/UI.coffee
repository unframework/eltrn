class UI
    render: (h) ->
        return h 'button', { onclick: -> }, new Date().toString()

module.exports = UI
