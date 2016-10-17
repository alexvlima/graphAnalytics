// const {readFileSync} = require('fs')
// const async = require('async')

module.exports = (server) => {
	const io = require('socket.io')(server)

	io.on('connection', function (socket) {
		console.log(socket.id)

		socket.on('search', (data) => {
			console.log(data)
		})


	})
}

// let data = JSON.parse(readFileSync('./public/m.json'))

// async.series([
// 	(callback) => {
// 		async.each(data.nodes, (node, next) => {
// 			setTimeout(() => {
// 				socket.emit('node', node)
// 				next()
// 			}, 50 * data.nodes.indexOf(node))
// 		}, function (err) {
// 			if (err)
// 				console.log(err)

// 			callback()
// 		})
// 	},
// 	(callback) => {
// 		async.each(data.edges, (edge, next) => {
// 			setTimeout(() => {
// 				socket.emit('edge', edge)
// 				next()
// 			}, 50 * data.edges.indexOf(edge))
// 		}, function (err) {
// 			if (err)
// 				console.log(err)

// 			callback()
// 		})
// 	},
// 	() => {
// 		socket.emit('stabilize')
// 	}
// ])