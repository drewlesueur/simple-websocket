net = require "net"
util = require "util"
events = require "events"
Server = net.Server
Stream = net.Socket
Crypto = require "crypto"
_ = require "underscore"
require("/home/drew/drews-mixins/drews-mixins.coffee").mixinWith(_)

allDigits = (str) ->
  str.replace(/\D/g, "") - 0

numberOfSpaces = (str) ->
  str.replace(/[^\ ]/g, "").length

pack = (num) -> 
  result = ''
  result += String.fromCharCode(num >> 24 & 0xFF)
  result += String.fromCharCode(num >> 16 & 0xFF)
  result += String.fromCharCode(num >> 8 & 0xFF)
  result += String.fromCharCode(num & 0xFF)
  return result

class WebSocketServer extends events.EventEmitter
  constructor: (args...) ->
    if args[0] instanceof Server
      @server = args[0]
    else
      @server = new Server args...
    @server.on 'connection', @handleConnection
  listen: (args...) => 
    @server.listen args...
  handleConnection: (socket) => 
    socket.on "data", (raw) =>
      @handshake socket, raw
  handshake : (socket, raw) =>
    str = raw.toString()
    console.log str
    if _.startsWith str, "GET / HTTP/1.1\r\nUpgrade: WebSocket\r\nConnection: Upgrade"
      console.log "web socket here we come"
      last = raw.binarySlice raw.length - 8
      console.log "LAST IS #{last} is #{last.length} chars long"
      req = str.split "\r\n"
      for line in req
        if _.startsWith line, "Origin:"
          origin = _.s line, "Origin:".length + 1
        if _(line).startsWith "Sec-WebSocket-Key1:"
          key1 = _.s line, "Sec-WebSocket-Key1:".length + 1
        if _(line).startsWith "Sec-WebSocket-Key2:"
          key2 = _.s line, "Sec-WebSocket-Key2:".length + 1
      console.log "key 1 is #{key1}"
      console.log "key 2 is #{key2}"
      num1 = allDigits key1
      num2 = allDigits key2
      spaces1 = numberOfSpaces key1
      spaces2 = numberOfSpaces key2
      final1 = pack parseInt(num1 / spaces1)
      final2 = pack parseInt(num2 / spaces2)
      hash = Crypto.createHash "md5"
      hash.update final1
      hash.update final2
      hash.update last
      ret =  "" +
        "HTTP/1.1 101 WebSocket Protocol Handshake\r\n" +
        "Upgrade: WebSocket\r\n" +
        "Connection: Upgrade\r\n" +
        "Sec-WebSocket-Origin: "+origin+"\r\n" +
        "Sec-WebSocket-Location: ws://#{hostname}:#{port}#{location}" +
        "\r\n\r\n" +
        hash.digest("binary")
      console.log()
      console.log ret
      socket.write ret, "binary"
      socket.removeListener "data", @handleData 
      webSocket = new WebSocket socket
      @emit "connection", (webSocket)
    else if _.startsWith str, "GET"
      content = "yo world"
      socket.write "HTTP/1.1 200 OK\r\n" +
        "Connection: close\r\n" +
        "Content-Type: text/html\r\n" +
        "Content-Length: #{content.length}\r\n\r\n" +
        content

class WebSocket extends events.EventEmitter
  constructor: (@socket) ->
    @socket.on "data", (data) => @handleData
    @socket.on "end", () => @handleEnd
    @socket.on "error", () => @handleError
    @emit "open"
  handleError: (exception) => @emit "error", exception
  handleEnd: (data) => @emit "close"
  handleData: (data) =>
    data = data.toString()
    data = _.s data, 1, -1
    @emit "message", data
  write: (data) ->
    @socket.write "\x00", "binary"
    @socket.write data, "utf8"
    @socket.write "\xff", "binary"
  close: () ->
    @socket.write "" #right?

exports.WebSocketServer = WebSocketServer
exports.WebSocket = WebSocket
exports.createServer = (options) ->
  server = new WebSocketServer()
  options = exports.options = options || {}
  hostname = options.hostname
  location = options.location || "/"
  port = options.port || 9999
  return server


#server = exports.createServer()
#console.log "here is server.listen2"
#console.log server.listen
#server.listen()
