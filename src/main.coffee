fs = require('fs')
convertBuffer = require('buffer-to-arraybuffer')

soundData = fs.readFileSync __dirname + '/../sample.mp3'
convolverSoundData = fs.readFileSync __dirname + '/../echo-chamber.wav'

console.log soundData.length

createAudioContext = ->
  if typeof window.AudioContext isnt 'undefined'
    return new window.AudioContext
  else if typeof window.webkitAudioContext isnt 'undefined'
    return new window.webkitAudioContext

  throw new Error('AudioContext not supported. :(')

context = createAudioContext()

soundSource = context.createBufferSource()
context.decodeAudioData convertBuffer(soundData), (buffer) ->
  soundSource.buffer = buffer
soundSource.loop = true
soundSource.loopEnd = 0.5
# soundSource.playbackRate.value = 0.5

convolver = context.createConvolver()
# context.decodeAudioData convertBuffer(soundData), (buffer) ->
#   convolver.buffer = buffer

# low-pass
filter = context.createBiquadFilter()
filter.type = 0
filter.Q.value = 12.5
filter.frequency.setValueAtTime 440, context.currentTime
filter.frequency.linearRampToValueAtTime 1760, context.currentTime + 8
filter.Q.setValueAtTime 15, context.currentTime
# filter.Q.linearRampToValueAtTime(5, 8)

soundSource.connect filter
filter.connect context.destination
# filter.connect(convolver)
# convolver.connect(context.destination)

# play/stop buttons
document.body.innerHTML = '<button id="play">Play</button><button id="stop">Stop</button>'
document.querySelector('#play').addEventListener 'click', ->
  soundSource.start 0
document.querySelector('#stop').addEventListener 'click', ->
  soundSource.stop 0
