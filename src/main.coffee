fs = require('fs')
vdomLive = require('vdom-live')
convertBuffer = require('buffer-to-arraybuffer')

UI = require('./UI.coffee')

STEP_COUNT = 16
TOTAL_LENGTH = 1.73913043 # 4 * (60seconds / 138bpm)

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

runSequence = (startTime, stepList) ->
  stepLength = TOTAL_LENGTH / STEP_COUNT

  for [ stepCol, stepRow ] in stepList
    stepStartTime = stepCol * TOTAL_LENGTH
    sliceStartTime = stepRow * TOTAL_LENGTH
    addStep startTime + stepStartTime, sliceStartTime, stepLength

vdomLive (renderLive) ->
  ui = new UI(STEP_COUNT)
  nextLoopStartTime = null

  setInterval ->
    if nextLoopStartTime is null
      ui.setActiveStep null
      return

    currentTime = context.currentTime
    remainder = nextLoopStartTime - currentTime

    # avoid starting in the past
    if remainder < 0
      nextLoopStartTime = currentTime
      remainder = 0

    if remainder < 0.2
      runSequence nextLoopStartTime, ui.getSteps()
      nextLoopStartTime += TOTAL_LENGTH

    activeLoopTime = (if remainder > TOTAL_LENGTH then TOTAL_LENGTH + TOTAL_LENGTH else TOTAL_LENGTH) - remainder
    activeStepIndex = Math.floor(STEP_COUNT * activeLoopTime / TOTAL_LENGTH)

    ui.setActiveStep activeStepIndex
  , 10

  document.body.style.textAlign = 'center';
  liveDOM = renderLive (h) ->
    h 'div', {
      style: {
        display: 'inline-block'
        marginTop: '50px'
      }
    }, [
      if nextLoopStartTime isnt null
        h 'button', { style: { fontSize: '24px' }, onclick: -> nextLoopStartTime = null }, 'Stop'
      else
        h 'button', { style: { fontSize: '24px' }, onclick: -> nextLoopStartTime = context.currentTime }, 'Play'
      ' '
      h 'button', { onclick: -> addStep(0, 0, TOTAL_LENGTH) }, 'Play Full Sample'
      h 'div', { style: { height: '20px' } }
      ui.render(h)
    ]

  document.body.appendChild liveDOM
