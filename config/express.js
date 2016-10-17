const express = require('express')
const bodyParser = require('body-parser')
const passport = require('passport')
const session = require('express-session')
const MongoStore = require('connect-mongo')(session)
const Cors = require('cors')
const app = express()

process.session = session({
	saveUninitialized: true,
	resave: true,
	secret: require('./config').SECRET,
	cookie: {
		maxAge: 15 * 60 * 1000,
		httpOnly: true
	},
	store: new MongoStore({
		mongooseConnection: require('mongoose').connection,
		autoRemove: 'interval',
		autoRemoveInterval: 1
	})
})

module.exports = () => {
	/* istanbul ignore if */
	if (process.env.NODE_ENV != 'test')
		app.use(require('morgan')('dev'))

	app.use(Cors({ 'allowedHeaders': ['Content-Type'] }))

	app.use(require('compression')())

	app.use(bodyParser.urlencoded({ extended: true }))
	app.use(bodyParser.json())

	app.use(require('method-override')())

	app.use('/fonts/', express.static(require('path').normalize(__dirname + '/../public/fonts')))
	app.use('/assets/', express.static(require('path').normalize(__dirname + '/../public/assets')))

	app.use(process.session)

	app.use(passport.initialize())
	app.use(passport.session())

	// require('../app/routes/user.server.route.js')(app)
	require('../app/routes/index.server.route.js')(app)

	return app
}	