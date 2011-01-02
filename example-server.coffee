users = []
ws = require("simple-websocket")
server = ws.createServer
  port: 9998
  hostname : "bomber.the.tl"
server.on "wsConnection", (stream) ->
  users.push stream
  stream.on "wsMessage", (message) ->
    ws.write stream, message + "say what"
server.listen ws.options.port

setInterval () ->
  for stream in users
    ws.write stream, "secondly checkup"
, 1000
