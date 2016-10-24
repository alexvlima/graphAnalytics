const {Twitter} = require('../lib/twitter.lib')

module.exports = (server) => {
	const io = require('socket.io')(server)

	io.on('connection', function (socket) {
		console.log('Connected: ' + socket.id)
		socket.twitter = new Twitter()


		socket.on('disconnect', () => {
			console.log('Disconnected: ' + socket.id)
			socket.twitter.stopStream()
		})

		socket.on('startStream', (data) => {
			console.log('Stream Started: ' + data.txt)
			socket.twitter.startStream(data.txt)
		})

		socket.on('stopStream', () => {
			console.log('Stream Stopped')
			socket.twitter.stopStream()
		})

		// Interfaces socket
		// definir funcoes
		// provisorio

		//envia um usuario novo		
		socket.twitter.on('newUser', (u) => {
			socket.emit('newUser', u)
		})

		//envia um tweet novo		
		socket.twitter.on('newTweet', (t) => {
			socket.emit('newTweet', t)
		})

	})
}