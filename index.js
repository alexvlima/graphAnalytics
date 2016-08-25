process.env.NODE_ENV = process.env.NODE_ENV || /* istanbul ignore next */ 'development'

const fs = require('fs')
const {CERT, KEY, HTTP, HTTPS} = require('./config/config')
const appRedirect = require('express')()
const app = require('./config/express')()

const server = require('https').createServer({
	cert: fs.readFileSync(CERT),
	key: fs.readFileSync(KEY)
}, app)

require('./app/utils/socket.server.utils')(server)

appRedirect.all('*', (req, res) => {
	res.redirect('https://' + req.hostname + req.path)
})

server.listen(HTTPS, () => {
	/* istanbul ignore if */
	if (process.env.NODE_ENV != 'test')
		console.info('Online ' + HTTPS)
})

require('http').createServer(appRedirect).listen(HTTP, () => {
	/* istanbul ignore if */
	if (process.env.NODE_ENV != 'test')
		console.info('Online ' + HTTP)
})

module.exports = app