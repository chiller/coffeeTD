class Route
  points: []
  
  draw: ->
    @context.strokeStyle = "#888";
    @context.beginPath()
    for i in [0...@points.length-1]
      @context.moveTo @points[i][0],@points[i][1]
      @context.lineTo @points[i+1][0],@points[i+1][1] 
    @context.stroke()
  constructor: (@context, @points) ->
  
  #gives back the speed vector for a given point on the route
  crossproduct: (ax,ay,bx,by_,cx,cy) -> 
    (cy - ay) * (bx - ax) - (cx - ax) * (by_ - ay)

  dotproduct: (ax,ay,bx,by_,cx,cy) ->
    (cx - ax) * (bx - ax) + (cy - ay)*(by_ - ay)
  


  between: (ax,ay,bx,by_,cx,cy) -> 
    if Math.abs(@crossproduct ax,ay,bx,by_,cx,cy) > 0 then return false
    #console.log "-1-",(@crossproduct ax,ay,bx,by_,cx,cy)
    if (@dotproduct ax,ay,bx,by_,cx,cy) < 0 then return false
    #console.log "-2-"
    if (@dotproduct ax,ay,bx,by_,cx,cy) >= ((ax-bx)*(ax-bx)+(ay-by_)*(ay-by_)) then return false
    #console.log "-3-"
    return true

  getv: (x,y) ->
    for i in [0...@points.length-1]
      [ax,ay] = @points[i] 
      [bx,by_] = @points[i+1]
      if @between ax,ay,bx,by_,x,y 
        vx = if ax != bx then (if ax>bx then -1 else 1) else 0
        vy = if ay != by_ then (if ay>by_ then -1 else 1) else 0
        #console.log x,y, vx, vy
        return [vx,vy]
      
    
    return [0,0]
        





class Entity
  x: 0, y: 0, vx: 0, vy: 0
  state: "green"
  constructor: (@context, @x, @y, @route, @name="unnamed") ->

  

class Bug extends Entity
  hp: 20
  update: ->
    [@vx, @vy] = @route.getv(@x, @y) 
    @x += @vx
    @y += @vy
    #@state = if @x > 200 and @x < 300 then "blue" else "green"

  draw: ->
    @context.fillStyle = if @state == "green" then 'rgba(0,180,0,0.8)' else  'rgba(0,0,180,0.8)'
    #@context.fillRect @x, @y, @hp, @hp
    @context.fillStyle = '#0F0'
    @context.beginPath();
    @context.arc(@x, @y, @hp, 0, Math.PI*2, true); 
    @context.closePath();
    @context.fill();

class Tower
  x: 0, y:0
  constructor: (@context, @x, @y) ->

  draw: ->
    @context.fillStyle = 'rgba(0,0,0,1)'
    @context.fillRect @x,@y,15,15
    
  update: (@entities )->
    for e in @entities
      #console.log Math.sqrt((e.x - @x)*(e.x - @x) + (e.y - @y) * (e.y - @y))
      if Math.sqrt((e.x - @x)*(e.x - @x) + (e.y - @y) * (e.y - @y)) < 100
        @context.beginPath()
        @context.strokeStyle = "#F00";
        @context.moveTo @x,@y
        @context.lineTo e.x,e.y
        @context.stroke()

        e.hp -= 0.2
        return true


class TdApp
  timeout: 50
  main: ->
    @createCanvas()
    @startNewGame()
    @addKeyObservers()

  startNewGame: ->
    @entities = []
    @route = new Route @context, [[100,100],[100,200],[200,200],
        [200,100], [300,100], [300,300],
        [400,300], [400,100], [520,100], 

      ]
    @towers = []
    #@towers.push(new Tower @context, 230, 220)
    #@towers.push(new Tower @context, 330, 220)
    @entities.push(new Bug @context, 100, 100, @route, "A")
    @runLoop()
  
  runLoop: ->
    setTimeout =>
      
      # Update position of entities
      @entities.forEach (e) -> e.update()
      
      console.log (e.name+e.hp for e in @entities)

      alive = []
      for e in @entities
        if e.hp > 0
          alive.push(e)
      @entities = alive

      # Clear the Canvas
      @clearCanvas()
      
      @drawField()
      @route.draw()
      @drawEntities()
      
      @towers.forEach (e) -> e.draw()
      
      e.update(@entities) for e in @towers

      @runLoop() unless @terminateRunLoop
    , @timeout

  drawField: ->
    @context.fillStyle = 'rgba(200,150,150,0.2)'
    @context.fillRect 50, 50, 600, 300


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

    $(".plus").click =>
      @timeout = @timeout/2

    $(".minus").click =>
      @timeout = @timeout*2

    $(".spawn").click =>
      console.log("spawn")
      @entities.push(new Bug @context, 100, 100, @route, Math.round(Math.random()*15).toString())

    $("#canvas").bind 'click', (event) =>
      console.log event
      @towers.push(new Tower @context, event.layerX, event.layerY)


window.onload = ->
    window.td = new TdApp
    window.td.main()