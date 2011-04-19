users = []
_ = require("underscore")
ws = require("./simple-websocket.coffee")
server = ws.createServer
  port: 9998
  hostname : "b.the.tl"
server.on "connection", (webSocket) ->
  users.push webSocket
  webSocket.on "message", (message) ->
    console.log "There was a message"
    for user in users
      if user == webSocket then continue
      console.log "writing a message"
      user.write message
  webSocket.on "close", () ->
    i = _.indexOf(users, webSocket)
    users.splice(i, 1)
console.log "listening on #{ws.options.hostname}:#{ws.options.port}"
server.listen ws.options.port

setInterval () ->
  for user in users
    user.write "secondly checkup"
, 10000
