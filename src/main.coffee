fs = require('fs')
vdomLive = require('vdom-live')
convertBuffer = require('buffer-to-arraybuffer')

Panel = require('./Panel.coffee')
UI = require('./UI.coffee')
Playback = require('./Playback.coffee')

STEP_COUNT = 16
TOTAL_LENGTH = 8 * 60 / 138

soundData = fs.readFileSync __dirname + '/../sample.mp3'

createAudioContext = ->
  if typeof window.AudioContext isnt 'undefined'
    return new window.AudioContext
  else if typeof window.webkitAudioContext isnt 'undefined'
    return new window.webkitAudioContext

  throw new Error('AudioContext not supported. :(')

context = createAudioContext()

fwdSoundBuffer = null
context.decodeAudioData convertBuffer(soundData), (buffer) ->
  fwdSoundBuffer = buffer

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

  currentPlayback = null

  document.body.style.textAlign = 'center';
  liveDOM = renderLive (h) ->
    h 'div', {
      style: {
        display: 'inline-block'
        marginTop: '50px'
      }
    }, [
      if currentPlayback isnt null
        h 'button', { style: { fontSize: '24px' }, onclick: -> currentPlayback.stop(); currentPlayback = null }, 'Stop'
      else
        h 'button', { style: { fontSize: '24px' }, onclick: -> currentPlayback = new Playback(context, fwdSoundBuffer, panel) }, 'Play'
      ' '
      h 'div', { style: { height: '20px' } }
      ui.render()
    ]

  document.body.appendChild liveDOM
