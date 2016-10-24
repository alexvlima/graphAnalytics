const {render, notFound} = require('../controllers/index.server.controller')

module.exports = (app) => {
	app.get('/', render)

	app.all('*', notFound)
}