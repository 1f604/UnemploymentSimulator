'use strict'

require './helpers'
$ = require 'jquery'
_ = require 'underscore'
Visualizer = require './visualizer/visualizer'
DAT = require 'dat-gui'
World = require './model/world'
settings = require './settings'

$ ->
  canvas = $('<canvas />', {id: 'canvas'})
  $(document.body).append(canvas)

  window.world = new World()
  world.load()
  if world.intersections.length is 0
    world.generateMap()
    world.carsNumber = 100
  window.visualizer = new Visualizer world
  visualizer.start()
  gui = new DAT.GUI()
  guiWorld = gui.addFolder 'world'
  guiWorld.open()
  guiWorld.add world, 'generateMap'
  guiWorld.add world, 'showjobs'
  guiVisualizer = gui.addFolder 'visualizer'
  guiVisualizer.open()
  guiVisualizer.add(visualizer, 'running').listen()
  guiVisualizer.add(visualizer, 'debug').listen()
  guiVisualizer.add(visualizer, 'jobgrowthrate').min(-0.02).max(0.01).step(0.0001).listen()
  #guiWorld.add(world, 'populationLimit').min(1).max(50).step(1).listen()
  guiWorld.add(world, 'birthrate').min(1).max(100).step(1).listen()
  guiWorld.add(world, 'suiciderate').min(0).max(100).step(1).listen()
  guiWorld.add(world, 'lifeExpectancy').min(1).max(140).step(1).listen()