const {Twitter} = require('../lib/twitter.lib')

module.exports = (server) => {
	const io = require('socket.io')(server)

	io.on('connection', function (socket) {
		console.log('Connected: ' + socket.id)
		socket.twitter = new Twitter()

		//A cada X segundos envidar a rede atualizada para o client
		//Opcao de setar o tempo de construcao da rede


		socket.on('startStream', (data) => {
			console.log(data)
			//TODO startar a stream aqui
		})
		
		socket.on('stopStream', (data) => {
			console.log(data)
			//TODO stopar a stream aqui
		})


	})
}