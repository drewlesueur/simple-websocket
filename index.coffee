net = require "net"
Server = net.Server
Streami = net.Stream
Crypto = require "crypto"
_ = require "underscore"
root._ = _
require "zextra/util.js"

hostname = "mcode.the.tl"
port = 9999

location = "/"


allDigits = (str) ->
  str.replace(/\D/g, "") - 0

numberOfSpaces = (str) ->
  str.replace(/[^\ ]/g, "").length

`
function pack(num) {
var result = '';
result += String.fromCharCode(num >> 24 & 0xFF);
result += String.fromCharCode(num >> 16 & 0xFF);
result += String.fromCharCode(num >> 8 & 0xFF);
result += String.fromCharCode(num & 0xFF);
return result;
};
`

exports.write = (stream, data) ->
  stream.write "\x00", "binary"
  stream.write data, "utf8"
  stream.write "\xff", "binary"

exports.close = (stream) ->
  stream.write "" #right?

exports.createServer = (options) ->
  server = new Server
  exports.options = options 
  hostname = options.hostname
  location = options.location || "/"
  port = options.port || 9999
  server.on 'connection', (stream) ->
    stream.on "data", (raw) ->
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

        final1 = pack(parseInt(num1 / spaces1))
        final2 = pack(parseInt(num2 / spaces2))
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
        stream.write ret, "binary"
        
        stream.on "data", (data) ->
          data = data.toString()
          data = _.s data, 1, -1
          stream.emit "wsMessage", data

        server.emit "wsConnection", (stream)
      else if _.startsWith str, "GET"
        content = "yo world"
        stream.write "HTTP/1.1 200 OK\r\n" +
          "Connection: close\r\n" +
          "Content-Type: text/html\r\n" +
          "Content-Length: #{content.length}\r\n\r\n" +
          content
  return server
