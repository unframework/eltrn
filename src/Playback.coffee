class Playback
  constructor: (@_context, @_soundBuffer, @_stepCount, @_totalLength, @_panel) ->
    activeChannelSet = []

    # extend current playing channels by one more step
    extendChannels = (stepStartTime, stepIndex, stepList) =>
      stepPos = stepIndex / @_stepCount
      stepEndTime = stepStartTime + @_totalLength / @_stepCount

      touchedSet = []

      for [ stepCol, stepRow, stepCount ] in stepList
        if stepPos >= stepCol and stepPos < stepCol + stepCount
          channelIndex = (@_stepCount + @_stepCount * stepRow - @_stepCount * stepCol) % @_stepCount

          touchedSet[channelIndex] = true
          currentChannelNode = activeChannelSet[channelIndex]

          # always start a new sound at beginning of measure
          if not currentChannelNode or stepIndex is 0
            soundSource = @_context.createBufferSource()
            soundSource.buffer = @_soundBuffer
            soundSource.start stepStartTime, stepRow * @_totalLength
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
      nextStepIndex = Math.floor(@_stepCount * nextLoopTime / @_totalLength)

      while nextStepIndex >= @_stepCount
        nextStepIndex -= @_stepCount
        currentLoopStartTime += @_totalLength

      if nextStepIndex isnt currentStepIndex
        currentStepIndex = nextStepIndex

        nextStepStartTime = currentLoopStartTime + @_totalLength * nextStepIndex / @_stepCount

        extendChannels nextStepStartTime, nextStepIndex, @_panel.getSteps()

        @_panel.setActiveStep nextStepIndex
    , 20

  stop: ->
    clearInterval @_intervalId
    @_intervalId = null

    @_panel.setActiveStep null

module.exports = Playback
