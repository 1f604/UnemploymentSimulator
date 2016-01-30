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
    @proportionality = 0.0358 #the proportionality constant is slightly too large but I can't be bothered to get it exactly right
    @constant2 = 0.57 #this is also slightly too large but I also can't be bothered to fix it 
    @constant = 300
    @set {}
    @poplimit = 10
    @populationLimit = 12
    @$canvas = $('#canvas')
    @canvas = @$canvas[0]
    @ctx = @canvas.getContext('2d')
    @graphics = new Graphics @ctx
    @birthrate = 50
    @suiciderate = 10
    @lifeExpectancy = 70
    @counter = @constant//@birthrate-1 #this is a hack. 
    @suiciderefreshrate = 30
    @suicidecounter = @suiciderefreshrate-1 

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

  displayInfo: ->
    prevpos = 0
    for id,car of @cars.all()
      pos = (car.trajectory.absolutePosition*@proportionality + @constant2)*6.9832+0.005 #magic numbers for the win
      diff = pos - prevpos
      prevpos = pos
      plim = @poplimit*6.9987
      pdiff = plim-pos
      jobs = window.jobs*-1.751 -0.35
#      console.log("diff: "+diff) 
#      console.log("poplimit: "+plim)
      console.log("I am "+car.age+" years old!")
      if car.employed
        console.log("I am employed!")
      else
        console.log("I am unemployed!")
        if car.immunity 
          console.log("I am expecting employment!")
#      console.log("pop-diff: "+pdiff)
    console.log("jobs: "+(window.jobs*-1.751 -0.35))

      #alert(" jobs: "+(window.jobs*-1.751 -0.35))
    null

  generateMap: (minX = -2, maxX = 2, minY = -2, maxY = 1) -> #let's have one lane for now
    @clear()
    map = {}
    gridSize = settings.gridSize
    step = gridSize
    @carsNumber = 100

    @poplimit = @populationLimit
    maxX=@poplimit
    window.poplimit = @poplimit
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
   # @drawSignals road for id, road of @roads.all()
    for id, intersection of @intersections.all()
      intersection.controlSignals.onTick delta
    for id, car of @cars.all() #move the cars
      car.move delta
      @removeCar car unless car.alive

  refreshCars: ->
    @addCars()
    @checkCars()
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
        if lane.numCars < @poplimit * 7 -5
          lane.numCars += 1

          car = new Car(lane,false)
          if lane.numCars < (window.jobs*-1.751 -0.35)
            car = new Car(lane,true)
          lane.cars.put car 
          @addCar car
    return false

  checkCars: ->
    counter = 0 
    employedcounter  = 0
    totalcounter = 0
    unfilled = 0 #no. unfilled positions
    for id,car of @cars.all()
      car.queueposition = counter
      counter++
      pos = (car.trajectory.absolutePosition*@proportionality + @constant2)*6.9832+0.005
      diff = pos - prevpos
      prevpos = pos
      plim = @poplimit*6.9987
      pdiff = plim-pos
      jobs = window.jobs*-1.751 -0.35
#      console.log("diff: "+diff) 
#      console.log("poplimit: "+plim)
      if car.queueposition < jobs-1 #if there are jobs available for you, don't lose hope :^)
        car.immunity = true
      else
        car.immunity = false 
      if pdiff+0.5 < jobs 
        car.setEmployed()
      else
        car.setUnemployed()
      if car.employed == true
        employedcounter++
      totalcounter++
    unemploymentrate = (Math.round(((totalcounter-employedcounter)/totalcounter)*10000)/100).toFixed(2)
    if jobs > employedcounter #if there are more jobs than people
      unfilled = jobs - employedcounter
      unfilledrate = (Math.round(((unfilled)/jobs)*10000)/100).toFixed(2)
      $('#textbox').css('color', "#bbff99")
      $('#textbox').text("Percentage of positions unfilled: "+unfilledrate+"%")

    else 
      if unemploymentrate < 40
        $('#textbox').css('color', "#bbff99")
      else
        $('#textbox').css('color', "#ff3333")
      $('#textbox').text("Unemployment rate: "+unemploymentrate+"%")
#    document.write("Employed: "+employedcounter+" Total: "+totalcounter)


  removeCars: ->
    @suicidecounter++
    if @suicidecounter >= @suiciderefreshrate
      @suicidecounter = 0
      #console.log("Time for another round of suicide watch!")
      for id,car of @cars.all()
        car.age += 1
        if car.age > @lifeExpectancy #you have outlived your usefulness
            car.lane.numCars -= 1
            @removeCar car
        else if car.employed == false and car.immunity == false #only consider suicide if you've lost hope :^)
          rnum = _.random 1, 100
          if rnum <= @suiciderate #kill yourself
            car.lane.numCars -= 1
            #lane.cars.pop car
            #car.setUnemployed()
            @removeCar car

module.exports = World
