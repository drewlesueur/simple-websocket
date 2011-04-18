users = []
ws = require("./simple-websocket.coffee")
server = ws.createServer
  port: 9998
  hostname : "b.the.tl"
server.on "connection", (webSocket) ->
  users.push stream
  webSocket.on "message", (message) ->
    for user in users
      if user == webSocket then continue
      user.write message
  webSocket.on "close", () ->
    i = _.indexOf(users, websocket)
    users = users.splice(i, 1)
console.log "listening on #{ws.options.hostname}:#{ws.options.port}"
server.listen ws.options.port

setInterval () ->
  for stream in users
    ws.write stream, "secondly checkup"
, 1000
