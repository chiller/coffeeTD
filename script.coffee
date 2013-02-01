class Route
  points: [] 
  draw: ->
    @context.strokeStyle = GAMESETTINGS.route_style;
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
    if (@dotproduct ax,ay,bx,by_,cx,cy) < 0 then return false
    if (@dotproduct ax,ay,bx,by_,cx,cy) >= ((ax-bx)*(ax-bx)+(ay-by_)*(ay-by_)) then return false
    return true
  #returns the speed vector depending on where bug is on route
  getv: (x,y) ->
    for i in [0...@points.length-1]
      [ax,ay] = @points[i] 
      [bx,by_] = @points[i+1]
      if @between ax,ay,bx,by_,x,y 
        vx = if ax != bx then (if ax>bx then -1 else 1) else 0
        vy = if ay != by_ then (if ay>by_ then -1 else 1) else 0
        return [vx,vy]   
    return [0,0]
        
class Entity
  x: 0, y: 0, vx: 0, vy: 0
  constructor: (@context, @x, @y, @route, @name="unnamed") ->

class Bug extends Entity
  hp: 20, clean: true
  update: ->
    [@vx, @vy] = @route.getv(@x, @y) 
    @x += @vx
    @y += @vy

  draw: ->
    @context.fillStyle = GAMESETTINGS.bug_fill_style
    @context.strokeStyle = if @clean then GAMESETTINGS.bug_stroke_style else GAMESETTINGS.bug_stroke_style_dirty
    @context.beginPath()
    @context.arc @x, @y, @hp, 0, Math.PI*2, true 
    @context.closePath()
    @context.fill()
    @context.stroke();

class Tower
  x: 0, y: 0, size: 5, 
  constructor: (@context, @x, @y) ->

  draw: ->
    @context.fillStyle = GAMESETTINGS.tower_fill_style
    @context.strokeStyle = GAMESETTINGS.tower_stroke_style
    @context.fillRect @x - @size, @y - @size, @size*2, @size*2
    @context.strokeRect @x - @size, @y - @size, @size*2, @size*2
    
  shoot: (@entities )->
    for e in @entities
      if Math.sqrt((e.x - @x)*(e.x - @x) + (e.y - @y) * (e.y - @y)) < GAMESETTINGS.tower_shoot_radius
        @context.beginPath()
        @context.strokeStyle = GAMESETTINGS.tower_shoot_style;
        @context.moveTo @x, @y
        @context.lineTo e.x, e.y
        @context.stroke()
        e.hp -= 0.1
        e.clean = false
        return true


class TdApp
  timeout: 50, towers: [], lives: 15, score: 0, towerscnt: 10
  random_bug: 0.01
  main: ->
    @createCanvas()
    @startNewGame()
    @addKeyObservers()

  startNewGame: ->
    @entities = []
    @route = new Route @context, GAMESETTINGS.route
    @entities.push(new Bug @context, 100, 100, @route, "A")
    @runLoop()
  
  runLoop: ->
    setTimeout =>
      # Update position of entities
      @randomSpawn()
      e.update() for e in @entities
      @clearBugs()
      e.clean = true for e in @entities
      # Clear the Canvas
      @clearCanvas()
      #draw stuff
      @drawField()
      @route.draw()
      e.shoot(@entities) for e in @towers
      tower.draw() for tower in @towers
      e.draw() for e in @entities when e.hp > 0
      
      $("#lives").html @lives
      $("#score").html @score
      $("#towers").html @towerscnt
      $("#diff").html Math.round(@random_bug*100)
      @runLoop() unless @terminateRunLoop or not @lives
    , @timeout

  randomSpawn: ->
    if Math.random() < @random_bug 
      @entities.push(new Bug @context, 100, 100, @route, Math.round(Math.random()*15).toString())
      @random_bug += 0.001
      
  clearBugs: ->
    @score+=10 for e in @entities when e.hp <= 0
    route_last = @route.points[@route.points.length - 1]
    for e in @entities
      if route_last[0] == e.x and route_last[1] == e.y 
        e.hp = 0
        @lives -= 1
    @entities = (e for e in @entities when e.hp > 0)
    
  drawField: ->
    @context.fillStyle = 'rgba(200,150,150,0.2)'
    @context.fillRect 50, 50, 600, 300
    
  createCanvas: ->
    @canvas = $('#canvas')[0]
    @context = @canvas.getContext '2d'
    [@canvas.width, @canvas.height] = [document.width, document.height]
    @context.lineWidth = 3

  clearCanvas: ->
    @context.clearRect 0, 0, @canvas.width, @canvas.height

  addKeyObservers: ->
    $(".stop").click => @terminateRunLoop = true    
    $(".start").click => @runLoop()
    $(".plus").click => @timeout = @timeout/2
    $(".minus").click => @timeout = @timeout*2
    $(".spawn").click => @entities.push(new Bug @context, 100, 100, @route, Math.round(Math.random()*15).toString())
    $("#canvas").bind 'click', (event) => 
      if @towerscnt > 0
        @towers.push(new Tower @context, event.layerX, event.layerY)
        @towerscnt -= 1
window.onload = ->
    window.td = new TdApp
    window.td.main()