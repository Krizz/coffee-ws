pack = (data) ->
  JSON.stringify data

unpack = (data) ->
  try
    JSON.parse data
  catch err
    null

class window.Client
  onHold = []
  events = {};
  ready = false
  constructor: (addr) ->
    @ws = new WebSocket addr
    @ws.onopen = () =>
      ready = true
      (@ws.send msg for msg in onHold)
      onHold = []
    @ws.onmessage = (message) =>
      data = unpack message.data
      if events[data.e]?
        fn = events[data.e]
        fn.call @, data.d

  emit: (event, data) ->
    message = pack e: event, d: data
    if not ready
      onHold.push message
    else
      @ws.send message

  on: (event, fn) ->
    events[event] = fn
    return @