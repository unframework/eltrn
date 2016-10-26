EventEmitter = require('events').EventEmitter
vec3 = require('gl-matrix').vec3
vec4 = require('gl-matrix').vec4
mat4 = require('gl-matrix').mat4

PanelRenderer = require('./PanelRenderer.coffee')

createCanvas = (w, h) ->
  viewCanvas = document.createElement('canvas')
  viewCanvas.width = w or window.innerWidth
  viewCanvas.height = h or window.innerHeight

  viewCanvas

class GLWidget
  constructor: (@_w, @_h, @_onInit, @_onUpdate, @_onDown) ->

  type: 'Widget'
  init: () ->
    canvas = createCanvas @_w, @_h

    canvas.onmousedown = (e) =>
      e.preventDefault()

      gesture = new EventEmitter()

      dx = e.layerX - e.screenX
      dy = e.layerY - e.screenY

      moveListener = (e) =>
        lx = e.screenX + dx
        ly = e.screenY + dy
        glX = (lx - @_w * 0.5) / (@_w * 0.5)
        glY = (@_h * 0.5 - ly) / (@_h * 0.5)
        gesture.emit('move', [ glX, glY ])

      # @todo when released outside the window, resolve on next click?
      upListener = =>
        document.removeEventListener 'mousemove', moveListener, false
        document.removeEventListener 'mouseup', upListener, false
        gesture.emit('end')

      document.addEventListener 'mousemove', moveListener, false
      document.addEventListener 'mouseup', upListener, false

      glX = (e.layerX - @_w * 0.5) / (@_w * 0.5)
      glY = (@_h * 0.5 - e.layerY) / (@_h * 0.5)

      @_onDown([ glX, glY ], gesture)

    canvas.ontouchstart = (e) =>
      e.preventDefault()

      gesture = new EventEmitter()

      # @todo use touch id
      dx = e.layerX - e.touches[0].screenX
      dy = e.layerY - e.touches[0].screenY

      moveListener = (e) =>
        lx = e.touches[0].screenX + dx
        ly = e.touches[0].screenY + dy
        glX = (lx - @_w * 0.5) / (@_w * 0.5)
        glY = (@_h * 0.5 - ly) / (@_h * 0.5)
        gesture.emit('move', [ glX, glY ])

      # @todo when released outside the window, resolve on next click?
      upListener = =>
        document.removeEventListener 'touchmove', moveListener, false
        document.removeEventListener 'touchend', upListener, false
        gesture.emit('end')

      document.addEventListener 'touchmove', moveListener, false
      document.addEventListener 'touchend', upListener, false

      glX = (e.layerX - @_w * 0.5) / (@_w * 0.5)
      glY = (@_h * 0.5 - e.layerY) / (@_h * 0.5)

      @_onDown([ glX, glY ], gesture)

    @_onInit canvas.getContext('experimental-webgl')
    @_onUpdate()

    canvas

  update: () ->
    @_onUpdate()
    undefined

class UI
  constructor: (@_panel) ->
    @_cameraTransform = mat4.create()
    @_cameraOffset = vec3.create()
    vec3.set @_cameraOffset, 0, 0, -20
    @_cameraPosition = vec3.create()
    vec3.set @_cameraPosition, 0, 0, 2

    @_currentGesture = null
    @_panelRenderer = null

  _convertClick: (pos) ->
    inverseTransform = mat4.create()
    mat4.invert inverseTransform, @_cameraTransform

    rayStart = vec3.fromValues(pos[0], pos[1], -1)
    vec3.transformMat4 rayStart, rayStart, inverseTransform

    rayEnd = vec3.fromValues(pos[0], pos[1], 1)
    vec3.transformMat4 rayEnd, rayEnd, inverseTransform

    [ rayStart, rayEnd ]

  render: () ->
    w = 800
    h = 600

    new GLWidget w, h, (gl) =>
      console.log 'GL init!'
      @_panelRenderer = new PanelRenderer(gl)
    , () =>
      mat4.perspective @_cameraTransform, 45, w / h, 1, 100
      mat4.translate @_cameraTransform, @_cameraTransform, @_cameraOffset
      mat4.rotateX @_cameraTransform, @_cameraTransform, -0.3
      mat4.translate @_cameraTransform, @_cameraTransform, @_cameraPosition

      @_panelRenderer.draw(@_cameraTransform, @_panel)
    , (gesturePos, gesture) =>
      if @_currentGesture
        return

      rayGesture = new EventEmitter()
      @_currentGesture = rayGesture

      gesture.on 'move', (pos) =>
        rayGesture.emit 'move', @_convertClick(pos)
      gesture.on 'end', =>
        rayGesture.emit 'end'
        @_currentGesture = null

      @_panelRenderer.click(@_convertClick(gesturePos), rayGesture, @_panel)

module.exports = UI
