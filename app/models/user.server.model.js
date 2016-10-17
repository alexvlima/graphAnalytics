const Mongoose = require('mongoose')
const Schema = Mongoose.Schema

const User = new Schema({
	id: {
		type: String,
		unique: true
	},

	name: String,
	screen_name: {
		type: String,
		unique: true
	},

	url: String,
	description: String,
	location: String,

	followers_count: String,
	friends_count: String,
	listed_count: String,
	favourite_count: String,
	statuses_count: String,

	created_at: String,

	utc_offset: String,
	time_zone: String,
	geo_enabled: String,
	lang: String,

	profile_background_image_url: String,
	profile_background_color: String,
	profile_image_url: String,
	profile_banner_url: String

})

User.index({
	id: 'text',
	name: 'text',
	screen_name: 'text',
	url: 'text',
	description: 'text',
	location: 'text'
})

Mongoose.model('User', User)