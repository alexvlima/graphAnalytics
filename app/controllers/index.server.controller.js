const {readFileSync} = require('fs')

exports.notFound = function (req, res) {
	res.status(404).end()
}

exports.render = function (req, res) {
	res.sendFile('./public/index.html')
}

exports.json = function (req, res) {
	res.status(200).json(JSON.parse(readFileSync('./public/m.json')))
}
