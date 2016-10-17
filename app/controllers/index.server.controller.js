const {readFileSync} = require('fs')
const path = require('path')

exports.notFound = function (req, res) {
	res.status(404).end()
}

exports.render = function (req, res) {
	res.sendFile(path.join(__dirname, '../../public/index.html'))
}

exports.json = function (req, res) {
	res.status(200).json(JSON.parse(readFileSync('./public/m.json')))
}
