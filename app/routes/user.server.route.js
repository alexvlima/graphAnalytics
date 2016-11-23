const User = require('../../app/controllers/user.server.controller')

module.exports = function (app) {

	app.route('/api/users')
		.get(User.get)
		.post(User.post)

	app.route('/api/user/:id')
		.get(User.getOne)
		.put(User.put)
		.patch(User.patch)
		.delete(User.delete)
}
