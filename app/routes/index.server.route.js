const {render} = require('../controllers/index.server.controller')

module.exports = (app) => app.all('*', render)