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
  guiWorld.add world, 'save'
  guiWorld.add world, 'load'
  guiWorld.add world, 'clear'
  guiWorld.add world, 'generateMap'
  guiVisualizer = gui.addFolder 'visualizer'
  guiVisualizer.open()
  guiVisualizer.add(visualizer, 'running').listen()
  guiVisualizer.add(visualizer, 'debug').listen()
  guiVisualizer.add(visualizer.zoomer, 'scale', 0.1, 2).listen()
  guiVisualizer.add(visualizer, 'jobgrowthrate').min(-0.02).max(0.01).step(0.0001).listen()
  guiWorld.add(world, 'carsNumber').min(0).max(200).step(1).listen()
  guiWorld.add(world, 'poplimit').min(1).max(50).step(1).listen()
  guiWorld.add(world, 'birthrate').min(1).max(100).step(1).listen()
  guiWorld.add(world, 'time').min(0).max(200).step(1).listen()
  guiWorld.add(world, 'suiciderate').min(0).max(100).step(1).listen()