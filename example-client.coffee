
$(document).ready () ->
 
 window.ws = new WebSocket "ws://b.the.tl:9998/"
 ws.onopen = () ->
   console.log "open"
   ws.send "hahaha"
 ws.onmessage = (e) ->
   console.log e.data
 ws.onclose = (e) ->
   console.log "closed!!"
 ws.onerror = (e) ->
    console.log "error"



