'use strict'

require '../helpers'
_ = require 'underscore'
Segment = require '../geom/segment'
{PI} = Math
{random} = Math
$ = require 'jquery'
require '../helpers'
_ = require 'underscore'
Car = require './car'
Graphics = require './graphics'
Point = require '../geom/point'
Intersection = require './intersection'
Road = require './road'
Pool = require './pool'
Rect = require '../geom/rect'
settings = require '../settings'

class Lane
  @numCars = 0
  @cars = null
  constructor: (@sourceSegment, @targetSegment, @road) ->
    @leftAdjacent = null
    @rightAdjacent = null
    @leftmostAdjacent = null
    @rightmostAdjacent = null
    @carsPositions = {}
    @update()
    @numCars = 0
    @cars = new Pool Car, null

  toJSON: ->
    obj = _.extend {}, this
    delete obj.carsPositions
    obj

  @property 'sourceSideId',
    get: -> @road.sourceSideId

  @property 'targetSideId',
    get: -> @road.targetSideId

  @property 'isRightmost',
    get: -> this is @.rightmostAdjacent

  @property 'isLeftmost',
    get: -> this is @.leftmostAdjacent

  @property 'leftBorder',
    get: ->
      new Segment @sourceSegment.source, @targetSegment.target

  @property 'rightBorder',
    get: ->
      new Segment @sourceSegment.target, @targetSegment.source

  update: ->
    @middleLine = new Segment @sourceSegment.center, @targetSegment.center
    @length = @middleLine.length
    @direction = @middleLine.direction

  getTurnDirection: (other) ->
    return @road.getTurnDirection other.road

  getDirection: ->
    @direction

  getPoint: (a) ->
    @middleLine.getPoint a

  addCarPosition: (carPosition) ->
    throw Error 'car is already here' if carPosition.id of @carsPositions
    @carsPositions[carPosition.id] = carPosition

  removeCar: (carPosition) ->
    throw Error 'removing unknown car' unless carPosition.id of @carsPositions
    delete @carsPositions[carPosition.id]

  getNext: (carPosition) ->
    throw Error 'car is on other lane' if carPosition.lane isnt this
    next = null
    bestDistance = Infinity
    for id, o of @carsPositions
      distance = o.position - carPosition.position
      if not o.free and 0 < distance < bestDistance
        bestDistance = distance
        next = o
    next

module.exports = Lane
