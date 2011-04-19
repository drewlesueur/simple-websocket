
$(document).ready () ->
 
 window.ws = new WebSocket "ws://b.the.tl:9998/"
 ws.onopen = () ->
   console.log "open"
 ws.onmessage = (e) ->
   data = JSON.parse e.data
   app[data[0]] data[1] 
 ws.onclose = (e) ->
   console.log "closed!!"
 ws.onerror = (e) ->
    console.log "error"

window.app = {}
app.addField = () ->
  app.field = document.createElement "div"
  $(app.field).css
    height: "320px"
    width: "320px"

  $(app.field).attr "id", "field"
  $('#wrapper').append app.field
  if $.os.ios or $.os.android or $.os.webos
    clicky = "touchstart"
  else
    clicky = "click"
  $('#field').bind clicky, (e) ->
    e.preventDefault()
    if e.touches
      e = e.touches[0]
    ws.send JSON.stringify ["repos"
      x: e.clientX
      y: e.clientY
  ]

app.getByCid = {}
app.renderUser = (user) ->
  if not (user.__cid of app.getByCid)
    app.users.push user
    user.dom = document.createElement "div"
    
    $(user.dom).html user.__cid
    $(user.dom).css
      "position": "absolute"
      top: "0"
      left: "0"
    app.getByCid[user.__cid] = user
    $('#field').append user.dom

  else
    oldUser = app.getByCid[user.__cid]
    user = _.extend oldUser, user
  $(user.dom).anim
    translateX: user.x + "px"
    translateY: user.y + "px"
app.users = []
app.updateUsers = (data) ->
  for user in data
    app.renderUser user

app.log = (str) ->
  #console.log str
app.tileWidth = 32
app.tileHeight = 32
app.renderScreen = (tiles) ->
  app.addField()
  x = 0
  y = 0
  if _.isString tiles
    tiles = tiles.split "\n"
  
  for row in tiles
    if _.isString row
      row = row.split ""
    for cell in row
      if _.isString cell
        str = cell
        cell = {}
        if str is "-"
          cell.color = "green"
        else if str is "o"
          cell.color = "#aaaaaa"

      tile = document.createElement "div"
      if "color" of cell
        $(tile).css "background-color" : cell.color
      $(tile).attr("data-pos", "#{x},#{y}").css
        position : "absolute"
        left: app.tileWidth * x + "px"
        top: app.tileHeight * y + "px"
        width: app.tileWidth + "px"
        height: app.tileHeight + "px"
      $('#field').append tile
      x++
    x = 0
    y++

