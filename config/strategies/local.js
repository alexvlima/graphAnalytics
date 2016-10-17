const Passport = require('passport')
const LocalStrategy = require('passport-local').Strategy
const User = require('mongoose').model('User')

module.exports = () => {
	Passport.use('local', new LocalStrategy((username, password, done) => {
		User.findOne({
			username: username
		}, (err, user) => {
			/* istanbul ignore next */
			if (err)
				return done(err)

			if (!user)
				return done(null, false, {
					message: 'Invalid Username'
				})

			if (!user.authenticate(user, password))
				return done(null, false, {
					message: 'Invalid password'
				})

			return done(null, user)
		})
	}))
}