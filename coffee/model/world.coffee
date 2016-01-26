'use strict'

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

class World
  constructor: ->
    @constant = 300
    @set {}
    @poplimit = 10
    @$canvas = $('#canvas')
    @canvas = @$canvas[0]
    @ctx = @canvas.getContext('2d')
    @graphics = new Graphics @ctx
    @birthrate = 50
    @counter = @constant//@birthrate-1 #this is a hack. 

  drawSignals: (road) ->
    lightsColors = [settings.colors.redLight, settings.colors.greenLight]
    intersection = road.target
    segment = road.targetSide
    sideId = road.targetSideId
    lights = intersection.controlSignals.state[sideId]

    @ctx.save()
    @ctx.translate segment.center.x, segment.center.y
    @ctx.rotate (sideId + 1) * PI / 2
    @ctx.scale 1 * segment.length, 1 * segment.length
    # map lane ending to [(0, -0.5), (0, 0.5)]
    @graphics.drawTriangle(
        new Point(0.2, 0.8),
        new Point(0.4, 0.5),
        new Point(0.6, 0.8)
    )
    @graphics.fill settings.colors.greenLight
    @ctx.restore()


  @property 'instantSpeed',
    get: ->
      speeds = _.map @cars.all(), (car) -> car.speed
      return 0 if speeds.length is 0
      return (_.reduce speeds, (a, b) -> a + b) / speeds.length

  set: (obj) ->
    obj ?= {}
    @intersections = new Pool Intersection, obj.intersections
    @roads = new Pool Road, obj.roads
    @cars = new Pool Car, obj.cars
    @carsNumber = 0
    @time = 0

  save: ->
    data = _.extend {}, this
    delete data.cars
    localStorage.world = JSON.stringify data

  load: (data) ->
    data = data or localStorage.world
    data = data and JSON.parse data
    return unless data?
    @clear()
    @carsNumber = data.carsNumber or 0
    for id, intersection of data.intersections
      @addIntersection Intersection.copy intersection
    for id, road of data.roads
      road = Road.copy road
      road.source = @getIntersection road.source
      road.target = @getIntersection road.target
      @addRoad road


  generateMap: (minX = -2, maxX = 2, minY = -2, maxY = 2) ->
    @clear()
    map = {}
    gridSize = settings.gridSize
    step = 5 * gridSize
    @carsNumber = 100
    maxX=@poplimit
    x=0
    y=0

    @counter = @constant//@birthrate - 1#this is a hack. 
    while y < maxY
        y +=1
        rect = new Rect 0, step * y, gridSize, gridSize
        intersection = new Intersection rect
        @addIntersection map[[0, y]] = intersection
        rect = new Rect step * maxX * 2, step * y, gridSize, gridSize
        intersection = new Intersection rect
        @addIntersection map[[maxX * 2, y]] = intersection
    for y in [0..maxY]
      previous = null
      for x in [0..maxX * 2]
        intersection = map[[x, y]]
        if intersection?
          @addRoad new Road intersection, previous if previous?
          previous = intersection
    null


  clear: ->
    @set {}

  onTick: (delta) =>
    throw Error 'delta > 1' if delta > 1
    @time += delta
    @refreshCars()
    @drawSignals road for id, road of @roads.all()
    for id, intersection of @intersections.all()
      intersection.controlSignals.onTick delta
    for id, car of @cars.all() #move the cars
      car.move delta
      @removeCar car unless car.alive

  refreshCars: ->
    @addCars()
    @removeCars()

  addRoad: (road) ->
    @roads.put road
    road.source.roads.push road
    road.target.inRoads.push road
    road.update()

  getRoad: (id) ->
    @roads.get id

  addCar: (car) ->
    @cars.put car

  getCar: (id) ->
    @cars.get(id)

  removeCar: (car) ->
    @cars.pop car

  addIntersection: (intersection) ->
    @intersections.put intersection

  getIntersection: (id) ->
    @intersections.get id

  addCars: ->
    @counter++
    if @counter >= @constant//@birthrate
      @counter = 0
      for id,road of @roads.all()
        lane = _.sample road.lanes
        if lane.numCars < 60
          lane.numCars += 1
          car = new Car lane
          lane.cars.put car 
          @addCar car
    return false

  removeCars: ->
        car = _.sample @cars.all()
        if car.employed == true
          car.lane.numCars -= 1
          #lane.cars.pop car
          @removeCar car

module.exports = World
