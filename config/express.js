const express = require('express')
const bodyParser = require('body-parser')
const app = express()

module.exports = () => {
	/* istanbul ignore if */
	if (process.env.NODE_ENV != 'test')
		app.use(require('morgan')('dev'))

	app.use(require('compression')())

	app.use(bodyParser.urlencoded({ extended: true }))
	app.use(bodyParser.json())

	app.use(require('method-override')())

	app.use('/', express.static(require('path').normalize(__dirname + '/../public')))

	app.use((req, res, next) => {
		res.header('Access-Control-Allow-Origin', '*')
		res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept')
		next()
	})

	require('../app/routes/index.server.route.js')(app)

	return app
}	