class Route
  points: []
  
  draw: ->
    @context.fillStyle = 'rgba(190,200,180,0.8)'
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
    console.log "-1-",(@crossproduct ax,ay,bx,by_,cx,cy)
    if (@dotproduct ax,ay,bx,by_,cx,cy) < 0 then return false
    console.log "-2-"
    if (@dotproduct ax,ay,bx,by_,cx,cy) >= ((ax-bx)*(ax-bx)+(ay-by_)*(ay-by_)) then return false
    console.log "-3-"
    return true

  getv: (x,y) ->
    for i in [0...@points.length-1]
      [ax,ay] = @points[i] 
      [bx,by_] = @points[i+1]
      if @between ax,ay,bx,by_,x,y 
        vx = if ax != bx then (if ax>bx then -1 else 1) else 0
        vy = if ay != by_ then (if ay>by_ then -1 else 1) else 0
        console.log x,y, vx, vy
        return [vx,vy]
      
    
    return [0,0]
        





class Entity
  x: 0, y: 0, vx: 0, vy: 0
  state: "green"
  constructor: (@context, @x, @y, @route) ->

  

class Bug extends Entity
  update: ->
    [@vx, @vy] = @route.getv(@x, @y) 
    @x += @vx
    @y += @vy
    #@state = if @x > 200 and @x < 300 then "blue" else "green"

  draw: ->
    @context.fillStyle = if @state == "green" then 'rgba(0,180,0,0.8)' else  'rgba(0,0,180,0.8)'
    @context.fillRect @x, @y, 10, 10


class TdApp
  timeout: 1000
  main: ->
    @createCanvas()
    @startNewGame()
    @addKeyObservers()

  startNewGame: ->
    @entities = []
    @route = new Route @context, [[100,100],[100,200],[200,200],
        [200,100], [300,100], [300,300],
        [400,300], [400,100], [320,100], [320,280],
        [380,280], [500,500],

      ]
    @entities.push(new Bug @context, 100, 100, @route)
    @runLoop()
  
  runLoop: ->
    setTimeout =>
      
      # Update position of entities
      @entities.forEach (e) -> e.update()

      

      # Clear the Canvas
      @clearCanvas()
      
      @drawField()
      @route.draw()
      @drawEntities()

      @runLoop() unless @terminateRunLoop
    , @timeout

  drawField: ->
    @context.fillStyle = 'rgba(200,150,150,0.2)'
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

    $(".plus").click =>
      @timeout = @timeout/2

    $(".minus").click =>
      @timeout = @timeout*2

window.onload = ->
    window.td = new TdApp
    window.td.main()