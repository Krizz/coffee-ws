CoffeeWs = require 'coffee-ws'
express = require 'express'
http = require 'http'
path = require 'path'
app = express()

server = http.createServer app
app.configure () ->
	app.set 'view engine', 'ejs'
	app.set 'views', __dirname + '/views'
	app.use express.static path.join __dirname, 'public'

app.get '/', (req, res) ->
	res.render 'index'

server.listen 80

ws = new CoffeeWs server: server

fn1 = (fn) ->
	console.log 'fn1'
	fn null

fn2 = (fn) ->
	console.log 'fn2'
	fn null

fn3 = (fn) ->
	@name = 'Test'
	console.log 'fn3'
	fn null

ws.on 'connection', (client) ->
	client
	.on 'ping', fn1, (err) ->
		console.log 'ping'
		@emit 'pong'
	.on 'test', fn1, fn2, fn3, (err, data) ->
		console.log @name, data
		@emit 'test', data