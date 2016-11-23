const {Twitter} = require('../lib/js/twitter.lib')
const {exec, execSync} = require('child_process')
const {words} = require('lodash')
const {forever} = require('async')

/* istanbul ignore next */
module.exports = (server) => {
	const io = require('socket.io')(server)

	io.on('connection', function (socket) {
		console.log('Connected: ' + socket.id)
		socket.twitter = new Twitter()

		socket.on('disconnect', () => {
			console.log('Disconnected: ' + socket.id)
			socket.twitter.stopStream()
			socket.stopped = true
		})

		socket.on('startStream', (data) => {
			console.log('Stream Started: ' + data.txt)

			socket.twitter.startStream(data.txt)


			socket.interval = forever(
				function (next) {
					let ws = ''

					for (let w of words(data.txt))
						ws += w + ','

					ws = ws.slice(0, -1)

					console.log('start')

					exec('rscript app/lib/r/filtered-tweet.lib.r --word=' + ws, { maxBuffer: 100000000 }, (error, stdout) => {
						if (error) {
							setTimeout(next, 5000)
							return console.error(`exec error: ${error}`)
						}

						// console.log(`stdout: ${stdout}`)
						// console.log(`stderr: ${stderr}`)

						console.log('end')

						socket.emit('graph', stdout.toString())

						setTimeout(next, 5000, socket.stopped)
					})
				},
				function (err) {
					socket.stopped = false
				}
			)


		})

		socket.on('stopStream', () => {
			console.log('Stream Stopped')
			socket.twitter.stopStream()
			socket.stopped = true
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