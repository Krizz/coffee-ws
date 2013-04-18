WebSocketServer = require('ws').Server
EventEmitter = require('events').EventEmitter
async = require('async')

pack = (data) ->
  JSON.stringify data

unpack = (data) ->
  try
    JSON.parse data
  catch err
    null

class Server extends EventEmitter
  constructor: (options)->
    @clients = []
    @wss = new WebSocketServer options
    @wss.on 'connection', (ws) =>
      client = new Client ws

      ws.on 'close', () =>
        @clients.splice @clients.indexOf client, 1

      @clients.push client
      @emit.call @, 'connection', client

class Client extends Server
  constructor: (client) ->
    @middleware = {}
    @ws = client
    @ws.on 'message', (message) =>
      @handleMessage message

  handleMessage: (message) ->
    data = unpack message
    middleware = @middleware[data.e]
    if middleware
      callback = middleware[middleware.length - 1]
      tasks = middleware.slice 0, middleware.length - 1

      #run all middleware in series
      async.series ( task.bind @ for task in tasks), (err, res) =>
        if not err
          callback.call @, null, data.d
        else
          callback.call @, err

  emit: (event, data) ->
    res = pack
      e: event
      d: data

    if @ws.readyState is 1
      @ws.send res

  on: (event, middleware...) ->
    @middleware[event] = middleware
    return @

module.exports = Server