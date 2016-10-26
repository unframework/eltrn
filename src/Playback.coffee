class Playback
  constructor: (@_context, @_soundBuffer, @_stepCount, @_totalLength, @_panel) ->
    @_activeChannelSet = []

    # extend current playing channels by one more step
    extendChannels = (stepStartTime, stepIndex, stepList) =>
      stepPos = stepIndex / @_stepCount

      # clear all play when restarting loop
      if stepIndex is 0
        for node, i in @_activeChannelSet when node
          node.stop stepStartTime
          @_activeChannelSet[i] = null

      touchedSet = []

      for [ stepCol, stepRow, stepCount ] in stepList
        if stepPos >= stepCol and stepPos < stepCol + stepCount
          channelIndex = (@_stepCount + @_stepCount * stepRow - @_stepCount * stepCol) % @_stepCount

          touchedSet[channelIndex] = true
          currentChannelNode = @_activeChannelSet[channelIndex]

          # start the new channel play without explicit stop
          if not currentChannelNode
            soundSource = @_context.createBufferSource()
            soundSource.buffer = @_soundBuffer
            soundSource.start stepStartTime, stepRow * @_totalLength
            soundSource.connect @_context.destination

            currentChannelNode = @_activeChannelSet[channelIndex] = soundSource

      # unlink and stop stale sources
      for node, i in @_activeChannelSet when node
        if not touchedSet[i]
          # set to stop at beginning of given new step
          @_activeChannelSet[i].stop stepStartTime
          @_activeChannelSet[i] = null

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

        @_panel.setActiveStep nextStepIndex # @todo pull instead of push (get renderer to track current playback)
    , 20

  stop: ->
    clearInterval @_intervalId
    @_intervalId = null

    for node, i in @_activeChannelSet
      node.stop @_context.currentTime
      @_activeChannelSet[i] = null

    @_panel.setActiveStep null

module.exports = Playback
