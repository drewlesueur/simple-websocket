_ = require "underscore"

screen = """
----------
-o-o-o-o--
----------
-o-o-o-o--
----------
-o-o-o-o--
----------
-o-o-o-o--
----------
-o-o-o-o--
----------
"""

users = []
removeByCid = (cid) ->
  for webSocket, index in users
    
    if (not webSocket) or (webSocket.__cid == cid)
      users.splice index, 1

ws = require("./simple-websocket.coffee")
server = ws.createServer
  port: 9998
  hostname : "b.the.tl"
server.on "connection", (webSocket) ->
  users.push webSocket
  webSocket.__cid = _.uniqueId()
  webSocket.x = 0
  webSocket.y = 0
  webSocket.write JSON.stringify  ["renderScreen", screen]
  webSocket.on "message", (message) ->
    console.log "the message is " + message
    data = JSON.parse message
    console.log "the first part is" + data[0]
    if data[0] of handle
      handle[data[0]] webSocket, data[1]
server.listen ws.options.port


handle = {}
handle.repos = (webSocket, info) ->
  console.log "got here"
  webSocket.oldx = webSocket.x
  webSocket.oldy = webSocket.y
  webSocket.hasChanged = true
  webSocket.x = info.x
  webSocket.y = info.y
  webSocket.on "close", ->
    
    i = _.indexOf users, webSocket
    users[i] = null
    
  
loopy = () -> 
  changes = []
  for webSocket, index in users
    try
      if webSocket.hasChanged
        changes.push
          __cid: webSocket.__cid
          x: webSocket.x
          y: webSocket.y
        webSocket.hasChanged = false
    catch e
      users.splice index, 1
  for webSocket,index in users
    if webSocket
      webSocket.write JSON.stringify ["updateUsers", changes]

setInterval loopy, 100
