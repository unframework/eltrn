fs = require('fs')
vdomLive = require('vdom-live')
convertBuffer = require('buffer-to-arraybuffer')

Panel = require('./Panel.coffee')
UI = require('./UI.coffee')

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
revSoundBuffer = null
context.decodeAudioData convertBuffer(soundData), (buffer) ->
  fwdSoundBuffer = buffer

  revSoundBuffer = context.createBuffer(
    buffer.numberOfChannels,
    buffer.length,
    buffer.sampleRate
  )

  for channelIndex in [ 0 ... buffer.numberOfChannels ]
    channelValues = new Float32Array(fwdSoundBuffer.getChannelData(channelIndex))
    Array.prototype.reverse.call channelValues

    revSoundBuffer.getChannelData(channelIndex).set channelValues

# low-pass
filter = context.createBiquadFilter()
filter.type = 'lowpass'
filter.Q.value = 52.5
filter.frequency.setValueAtTime 440, context.currentTime
filter.frequency.linearRampToValueAtTime 1760, context.currentTime + 8
filter.Q.setValueAtTime 15, context.currentTime
filter.Q.linearRampToValueAtTime(5, 8)
filter.connect(context.destination)

addStep = (startTime, sliceStartTime, sliceLength, sliceSourceLength) ->
  soundSource = context.createBufferSource()
  soundSource.buffer = if sliceSourceLength > 0 then fwdSoundBuffer else revSoundBuffer

  if sliceSourceLength > 0
    soundSource.start startTime, TOTAL_LENGTH + sliceStartTime, sliceSourceLength
    soundSource.playbackRate.value = sliceSourceLength / sliceLength
  else
    soundSource.start startTime, TOTAL_LENGTH - sliceStartTime, -sliceSourceLength
    soundSource.playbackRate.value = -sliceSourceLength / sliceLength

  soundSource.connect filter

runSequence = (startTime, stepList) ->
  for [ stepCol, stepRow, stepCount, stepSourceCount ] in stepList
    stepStartTime = stepCol * TOTAL_LENGTH
    sliceStartTime = stepRow * TOTAL_LENGTH
    sliceLength = stepCount * TOTAL_LENGTH
    sliceSourceLength = stepSourceCount * TOTAL_LENGTH
    addStep startTime + stepStartTime, sliceStartTime, sliceLength, sliceSourceLength

vdomLive (renderLive) ->
  panel = new Panel(STEP_COUNT)
  ui = new UI(panel)

  currentLoopStartTime = null
  nextLoopStartTime = null

  setInterval ->
    currentTime = context.currentTime

    # schedule next loop
    if nextLoopStartTime isnt null and nextLoopStartTime < currentTime + 0.2
      # avoid starting in the past
      if nextLoopStartTime < currentTime
        nextLoopStartTime = currentTime

      # start current loop display
      if currentLoopStartTime is null
        currentLoopStartTime = nextLoopStartTime

      runSequence nextLoopStartTime, panel.getSteps()
      nextLoopStartTime += TOTAL_LENGTH

    # advance current loop when done
    if currentLoopStartTime isnt null and currentTime > currentLoopStartTime + TOTAL_LENGTH
      if nextLoopStartTime isnt null
        currentLoopStartTime += TOTAL_LENGTH
      else
        currentLoopStartTime = null

    # display current loop if active
    if currentLoopStartTime isnt null
      activeLoopTime = currentTime - currentLoopStartTime
      activeStepIndex = Math.floor(STEP_COUNT * activeLoopTime / TOTAL_LENGTH)

      panel.setActiveStep activeStepIndex
    else
      panel.setActiveStep null

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
        h 'button', { style: { fontSize: '24px' }, onclick: -> currentLoopStartTime = null; nextLoopStartTime = null }, 'Stop'
      else
        h 'button', { style: { fontSize: '24px' }, onclick: -> nextLoopStartTime = context.currentTime }, 'Play'
      ' '
      h 'button', { onclick: -> addStep(0, 0, TOTAL_LENGTH) }, 'Play Full Sample'
      h 'div', { style: { height: '20px' } }
      ui.render()
    ]

  document.body.appendChild liveDOM
