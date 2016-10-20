const {DB} = require('./config')
const mongoose = require('mongoose')

module.exports = () => {

	mongoose.Promise = global.Promise

	mongoose.connect(DB, (err) => {
		/* istanbul ignore next */
		if (err) {
			console.error(err)
			process.exit(0)	
		}
	})

	// Load models
	require('../app/models/user.server.model')
	require('../app/models/tweet.server.model')
}