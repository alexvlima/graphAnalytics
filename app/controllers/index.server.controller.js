const path = require('path')

exports.notFound = function (req, res) {
	res.status(404).end()
}

exports.render = function (req, res) {
	res.sendFile(path.join(__dirname, '../../public/index.html'))
}