const {Twitter} = require('../lib/js/twitter.lib')
const {parallel} = require('async')
const mongoose = require('mongoose')
const User = mongoose.model('User')
const Tweet = mongoose.model('Tweet')

/* istanbul ignore next */
module.exports = (server) => {
	const io = require('socket.io')(server)

	io.on('connection', function (socket) {
		console.log('Connected: ' + socket.id)
		socket.twitter = new Twitter()


		socket.on('disconnect', () => {
			console.log('Disconnected: ' + socket.id)
			socket.twitter.stopStream()
			clearInterval(socket.interval)
		})

		socket.on('startStream', (data) => {
			console.log('Stream Started: ' + data.txt)

			socket.twitter.startStream(data.txt)

			socket.interval = setInterval(rLoop, 3000)
		})

		socket.on('stopStream', () => {
			console.log('Stream Stopped')
			socket.twitter.stopStream()
			clearInterval(socket.interval)
		})

		// Interfaces socket
		socket.twitter.on('newUser', (u) => {
			// socket.emit('newUser', u)
		})

		//envia um tweet novo		
		socket.twitter.on('newTweet', (t) => {
			// socket.emit('newTweet', t)
		})

	})
}

/* istanbul ignore next */
function rLoop() {
	return parallel({
		tweets: (callback) => {
			Tweet.find({}, (err, result) => {
				// processamento para o R
				callback(null, result)
			})
		},
		users: (callback) => {
			User.find({}, (err, result) => {
				// processamento para o R
				callback(null, result)
			})
		}
	}, (err, results) => {
		// chama o R e emita o socket pro cliente
		for (let k in results)
			console.log(k)
	})
}