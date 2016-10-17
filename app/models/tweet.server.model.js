const Mongoose = require('mongoose')
const Schema = Mongoose.Schema

const Tweet = new Schema({
	id: {
		type: String,
		unique: true
	},

	text: String,
	created_at: String,

	in_reply_to_status_id: String,
	in_reply_to_user_id: String,
	in_reply_to_screen_name: String,

	user: String,

	lang: String,
	timestamp_ms: String,

	retweet_count: String,
	favorite_count: String,

})

Tweet.index({
	id: 'text',
	text: 'text',
	created_at: 'text',
	user: 'text',
	timestamp_ms: 'text',
	in_reply_to_status_id: 'text',
	in_reply_to_user_id: 'text',
	in_reply_to_screen_name: 'text'
})

Mongoose.model('Tweet', Tweet)