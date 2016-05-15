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
  constructor: (@_w, @_h, @_onInit, @_onUpdate) ->

  type: 'Widget'
  init: () ->
    canvas = createCanvas @_w, @_h
    @_onInit canvas.getContext('experimental-webgl')

    canvas

  update: () ->
    @_onUpdate()
    undefined

class UI
  constructor: (@_panel) ->
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
      cameraTransform = mat4.create()
      mat4.perspective cameraTransform, 45, w / h, 1, 100
      mat4.translate cameraTransform, cameraTransform, @_cameraOffset
      mat4.rotateX cameraTransform, cameraTransform, -0.3
      mat4.translate cameraTransform, cameraTransform, @_cameraPosition

      @_panelRenderer.draw(cameraTransform, @_panel)

module.exports = UI
