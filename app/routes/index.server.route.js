const {render, json, notFound} = require('../controllers/index.server.controller')

module.exports = (app) => {
	app.get('/', render)

	app.get('/api/json', json)
	
	app.all('*', notFound)
}