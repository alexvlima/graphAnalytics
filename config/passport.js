const Passport = require('passport')
const Mongoose = require('mongoose')
const User = Mongoose.model('User')

module.exports = () => {

	Passport.serializeUser((user, done) => {
		done(null, { id: user.id, role: user.role })
	})

	Passport.deserializeUser((user, done) => {
		User.findOne({
			_id: user.id
		}, '-password -salt', (err, user) => {
			done(err, user)
		})
	})

	require('./strategies/local.js')()
}