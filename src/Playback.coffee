STEP_COUNT = 16
TOTAL_LENGTH = 8 * 60 / 138

class Playback
  constructor: (@_context, @_soundBuffer, @_panel) ->
    activeChannelSet = []

    # extend current playing channels by one more step
    extendChannels = (stepStartTime, stepIndex, stepList) =>
      stepPos = stepIndex / STEP_COUNT
      stepEndTime = stepStartTime + TOTAL_LENGTH / STEP_COUNT

      touchedSet = []

      for [ stepCol, stepRow, stepCount ] in stepList
        if stepPos >= stepCol and stepPos < stepCol + stepCount
          channelIndex = (STEP_COUNT + STEP_COUNT * stepRow - STEP_COUNT * stepCol) % STEP_COUNT

          touchedSet[channelIndex] = true
          currentChannelNode = activeChannelSet[channelIndex]

          # always start a new sound at beginning of measure
          if not currentChannelNode or stepIndex is 0
            soundSource = @_context.createBufferSource()
            soundSource.buffer = @_soundBuffer
            soundSource.start stepStartTime, stepRow * TOTAL_LENGTH
            soundSource.connect @_context.destination

            currentChannelNode = activeChannelSet[channelIndex] = soundSource

          currentChannelNode.stop stepEndTime

      # unlink stale sources
      for node, i in activeChannelSet
        if node and not touchedSet[i]
          activeChannelSet[i] = null

    currentLoopStartTime = @_context.currentTime
    currentStepIndex = null

    # @todo weird doubling of sound when first starting
    extendChannels currentLoopStartTime, 0, @_panel.getSteps()
    @_panel.setActiveStep 0

    @_intervalId = setInterval =>
      currentTime = @_context.currentTime

      # activate next step when we are at least one interval away
      nextLoopTime = currentTime + 0.03 - currentLoopStartTime
      nextStepIndex = Math.floor(STEP_COUNT * nextLoopTime / TOTAL_LENGTH)

      while nextStepIndex >= STEP_COUNT
        nextStepIndex -= STEP_COUNT
        currentLoopStartTime += TOTAL_LENGTH

      if nextStepIndex isnt currentStepIndex
        currentStepIndex = nextStepIndex

        nextStepStartTime = currentLoopStartTime + TOTAL_LENGTH * nextStepIndex / STEP_COUNT

        extendChannels nextStepStartTime, nextStepIndex, @_panel.getSteps()

        @_panel.setActiveStep nextStepIndex
    , 20

  stop: ->
    clearInterval @_intervalId
    @_intervalId = null

    @_panel.setActiveStep null

module.exports = Playback
