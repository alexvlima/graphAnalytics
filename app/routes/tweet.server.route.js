const Tweet = require('../../app/controllers/tweet.server.controller')

module.exports = function (app) {

	app.route('/api/tweets')
		.get(Tweet.get)
		.post(Tweet.post)

	app.route('/api/tweet/:id')
		.get(Tweet.getOne)
		.put(Tweet.put)
		.patch(Tweet.patch)
		.delete(Tweet.delete)
}
