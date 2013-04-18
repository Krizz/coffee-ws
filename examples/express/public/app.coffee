client = new Client 'ws://127.0.0.1:80'

client
.on 'pong', (data) ->
	console.log 'pong'
	@emit('ping', '')

.on 'test', (data) ->
	console.log data

client.emit 'ping', {}
client.emit 'test', text: 'Just A Test'