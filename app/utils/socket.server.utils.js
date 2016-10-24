const {Twitter} = require('../lib/twitter.lib')

module.exports = (server) => {
	const io = require('socket.io')(server)

	io.on('connection', function (socket) {
		console.log('Connected: ' + socket.id)
		socket.twitter = new Twitter()

		socket.twitter.on('newUser', (u) => {
			socket.emit('newUser', u)
		})

		socket.twitter.on('newTweet', (t) => {
			socket.emit('newTweet', t)
		})

		socket.on('disconnect', () => {
			console.log('Disconnected: ' + socket.id)
			socket.twitter.stopStream()
		})

		//A cada X segundos envidar a rede atualizada para o client
		//Opcao de setar o tempo de construcao da rede
		socket.on('startStream', (data) => {
			console.log(data)
			socket.twitter.startStream(data.txt)
			//TODO startar a stream aqui
		})

		socket.on('stopStream', () => {
			socket.twitter.stopStream()
			//TODO stopar a stream aqui
		})


	})
}