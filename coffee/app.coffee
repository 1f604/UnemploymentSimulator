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
  textbox = $('<div />', {id: 'textbox'})
  $(document.body).append(textbox)
  $('#textbox').css('left', "50%")
  $('#textbox').css('font-family', "Futura")
  $('#textbox').css('transform', "translateX(-50%)")
  $('#textbox').css('top', "10px")
  $('#textbox').css('position', "absolute")
  $('#textbox').css('color', "#bbff99")
  $('#textbox').text("Unemployment rate: 100%")
  copyrightnotice = $('<div />', {id: 'copyrightnotice'})
  $(document.body).append(copyrightnotice)
  $('#copyrightnotice').css('left', "50%")
  $('#copyrightnotice').css('font-family', "Futura")
  $('#copyrightnotice').css('font-size', "10px")
  $('#copyrightnotice').css('transform', "translateX(-50%)")
  $('#copyrightnotice').css('bottom', "10px")
  $('#copyrightnotice').css('position', "absolute")
  $('#copyrightnotice').css('color', "#bbff99")
  $('#copyrightnotice').html('<a href="https://github.com/volkhin/RoadTrafficSimulator">This program is a modification of Road Traffic Simulator, click here to view original (Copyright (C) 2014 Artem Volkhin)</a>')


#<div style="position: absolute; bottom: 0; left: 0; border: 0;"  alt="Original Source" ></div>


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
  guiWorld.add world, 'displayInfo'
  guiVisualizer = gui.addFolder 'visualizer'
  guiVisualizer.open()
  guiVisualizer.add(visualizer, 'running').listen()
  guiVisualizer.add(visualizer, 'jobgrowthrate').min(-0.02).max(0.01).step(0.0001).listen()
  guiVisualizer.add(visualizer, 'jobLimit').min(0).max(100).step(0.0001).listen()
  guiWorld.add(world, 'populationLimit').min(1).max(50).step(1).listen()
  guiWorld.add(world, 'birthrate').min(1).max(100).step(1).listen()
  guiWorld.add(world, 'suiciderate').min(0).max(100).step(1).listen()
  guiWorld.add(world, 'lifeExpectancy').min(22).max(140).step(1).listen()