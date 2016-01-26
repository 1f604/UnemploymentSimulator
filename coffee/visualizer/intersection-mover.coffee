'use strict'

require '../helpers.coffee'
Tool = require './tool.coffee'

class ToolIntersectionMover extends Tool
  constructor: ->
    super arguments...
    @intersection = null

module.exports = ToolIntersectionMover
