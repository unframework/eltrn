vdomLive = require('vdom-live')

Panel = require('./Panel.coffee')
UI = require('./UI.coffee')
Playback = require('./Playback.coffee')

STEP_COUNT = 16
TOTAL_LENGTH = 8 * 60 / 138

createAudioContext = ->
  if typeof window.AudioContext isnt 'undefined'
    return new window.AudioContext
  else if typeof window.webkitAudioContext isnt 'undefined'
    return new window.webkitAudioContext

  throw new Error('AudioContext not supported. :(')

context = createAudioContext()

loadData = (url, cb) ->
  request = new XMLHttpRequest()
  request.open 'GET', url, true
  request.responseType = 'arraybuffer'

  request.onload = ->
    done = false

    context.decodeAudioData request.response, (buffer) ->
      done = true
      cb buffer

    # silly hack to make sure that screen refreshes on load
    intervalId = setInterval (->
      if done
        clearInterval intervalId
    ), 300

  request.send();

# low-pass
filter = context.createBiquadFilter()
filter.type = 'lowpass'
filter.Q.value = 52.5
filter.frequency.setValueAtTime 440, context.currentTime
filter.frequency.linearRampToValueAtTime 1760, context.currentTime + 8
filter.Q.setValueAtTime 15, context.currentTime
filter.Q.linearRampToValueAtTime(5, 8)
filter.connect(context.destination)

vdomLive (renderLive) ->
  panel = new Panel(STEP_COUNT)
  ui = new UI(panel)

  fwdSoundBuffer = null
  loadData 'sample.mp3', (buffer) ->
    fwdSoundBuffer = buffer

  currentPlayback = null

  document.body.style.textAlign = 'center';
  liveDOM = renderLive (h) ->
    if fwdSoundBuffer then h 'div', {
      style: {
        display: 'inline-block'
        marginTop: '50px'
      }
    }, [
      if currentPlayback isnt null
        h 'button', { style: { fontSize: '24px' }, onclick: -> currentPlayback.stop(); currentPlayback = null }, 'Stop'
      else
        h 'button', { style: { fontSize: '24px' }, onclick: -> currentPlayback = new Playback(context, fwdSoundBuffer, STEP_COUNT, TOTAL_LENGTH, panel) }, 'Play'
      ' '
      h 'div', { style: { height: '20px' } }
      ui.render()
    ] else h 'div', [ 'Loading sound sample' ]

  document.body.appendChild liveDOM
