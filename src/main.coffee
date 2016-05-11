fs = require('fs')
vdomLive = require('vdom-live')
convertBuffer = require('buffer-to-arraybuffer')

UI = require('./UI.coffee')

soundData = fs.readFileSync __dirname + '/../sample.mp3'
convolverSoundData = fs.readFileSync __dirname + '/../echo-chamber.wav'

createAudioContext = ->
  if typeof window.AudioContext isnt 'undefined'
    return new window.AudioContext
  else if typeof window.webkitAudioContext isnt 'undefined'
    return new window.webkitAudioContext

  throw new Error('AudioContext not supported. :(')

context = createAudioContext()

soundBuffer = null
context.decodeAudioData convertBuffer(soundData), (buffer) ->
  soundBuffer = buffer

# convolver = context.createConvolver()
# context.decodeAudioData convertBuffer(soundData), (buffer) ->
#   convolver.buffer = buffer

# low-pass
# filter = context.createBiquadFilter()
# filter.type = 'lowpass'
# filter.Q.value = 12.5
# filter.frequency.setValueAtTime 440, context.currentTime
# filter.frequency.linearRampToValueAtTime 1760, context.currentTime + 8
# filter.Q.setValueAtTime 15, context.currentTime
# filter.Q.linearRampToValueAtTime(5, 8)

# filter.connect(convolver)
# convolver.connect(context.destination)

addStep = (startTime, endTime) ->
  soundSource = context.createBufferSource()
  soundSource.buffer = soundBuffer
  soundSource.start startTime
  soundSource.stop endTime
  soundSource.connect context.destination

runSequence = ->
  startTime = context.currentTime

  addStep startTime, startTime + 0.5
  addStep startTime + 1, startTime + 1.5

vdomLive (renderLive) ->
  ui = new UI()

  liveDOM = renderLive (h) ->
    h 'div', [
      h 'button', { onclick: -> runSequence() }, 'Play'
      ui.render(h)
    ]

  document.body.appendChild liveDOM
