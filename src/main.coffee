fs = require('fs')
vdomLive = require('vdom-live')
convertBuffer = require('buffer-to-arraybuffer')

UI = require('./UI.coffee')

STEP_COUNT = 16
TOTAL_LENGTH = 4

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

addStep = (startTime, sliceStartTime, sliceLength) ->
  soundSource = context.createBufferSource()
  soundSource.buffer = soundBuffer
  soundSource.start startTime, sliceStartTime, sliceLength
  soundSource.connect context.destination

runSequence = (stepList) ->
  startTime = context.currentTime
  stepLength = TOTAL_LENGTH / STEP_COUNT

  for [ stepCol, stepRow ] in stepList
    stepStartTime = stepCol * TOTAL_LENGTH
    addStep startTime + stepStartTime, stepStartTime, stepLength

vdomLive (renderLive) ->
  ui = new UI(STEP_COUNT)

  liveDOM = renderLive (h) ->
    h 'div', [
      h 'button', { onclick: -> addStep(0, 0, TOTAL_LENGTH) }, 'Play Full Sample'
      h 'button', { onclick: -> runSequence(ui.getSteps()) }, 'Play'
      ui.render(h)
    ]

  document.body.appendChild liveDOM
