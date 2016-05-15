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
  constructor: (@_w, @_h, @_onInit, @_onUpdate, @_onClick) ->

  type: 'Widget'
  init: () ->
    canvas = createCanvas @_w, @_h

    canvas.onclick = (e) =>
      glX = (e.layerX - @_w * 0.5) / (@_w * 0.5)
      glY = (@_h * 0.5 - e.layerY) / (@_h * 0.5)

      @_onClick glX, glY

    @_onInit canvas.getContext('experimental-webgl')

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

    @_panelRenderer = null

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
    , (glX, glY) =>
      inverseTransform = mat4.create()
      mat4.invert inverseTransform, @_cameraTransform

      rayStart = vec3.fromValues(glX, glY, -1)
      vec3.transformMat4 rayStart, rayStart, inverseTransform
      rayEnd = vec3.fromValues(glX, glY, 1)
      vec3.transformMat4 rayEnd, rayEnd, inverseTransform

      @_panelRenderer.click(rayStart, rayEnd, @_panel)

module.exports = UI
