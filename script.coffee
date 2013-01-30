class Entity
  x: 0, y: 0, vx: 1, vy: 0
  state: "green"
  constructor: (@context, @x, @y) ->

  

class Bug extends Entity
  update: -> 
    @x += @vx
    @y += @vy
    @state = if @x > 200 and @x < 300 then "blue" else "green"

  draw: ->
    @context.fillStyle = if @state == "green" then 'rgba(0,180,0,0.8)' else  'rgba(0,0,180,0.8)'
    @context.fillRect @x, @y, 10, 10


class TdApp
  main: ->
    @createCanvas()
    @startNewGame()
    @addKeyObservers()

  startNewGame: ->
    @entities = []
    @entities.push(new Bug @context, 55, 55)

    @runLoop()
  
  runLoop: ->
    setTimeout =>
      
      # Update position of entities
      @entities.forEach (e) -> e.update()


      # Clear the Canvas
      @clearCanvas()
      
      @drawField()

      @drawEntities()

      @runLoop() unless @terminateRunLoop
    , 10

  drawField: ->
    @context.fillStyle = 'rgba(200,150,150,0.8)'
    @context.fillRect 50, 50, 600, 400

  drawEntities: ->
    e.draw() for e in @entities
    
  createCanvas: ->
    @canvas = $('#canvas')[0]
    @context = @canvas.getContext '2d'
    @canvas.width = document.width
    @canvas.height = document.height

  clearCanvas: ->
    @context.clearRect 0, 0, @canvas.width, @canvas.height

  addKeyObservers: ->
    $(".stop").click =>
      @terminateRunLoop = true    

    $(".start").click =>
      @terminateRunLoop = true
    
    $(".left").click =>
      @entities[0].vx = -1
      @entities[0].vy = 0
    $(".right").click =>
      @entities[0].vx = 1
      @entities[0].vy = 0
    $(".up").click =>
      @entities[0].vy = -1
      @entities[0].vx = 0    
    $(".down").click =>
      @entities[0].vy = 1
      @entities[0].vx = 0

window.onload = ->
    td = new TdApp
    td.main()