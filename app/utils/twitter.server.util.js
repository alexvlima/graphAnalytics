'use strict'

const {until} = require('async')
const Twitter = require('twitter')

const client = new Twitter({
	consumer_key: '',
	consumer_secret: '',
	access_token_key: '',
	access_token_secret: ''
})

let web = {
	users: [],
	links: []
}

let cursor = -1

until(() => cursor == 0, (callback) => {
	client.get('friends/list', { screen_name: 'sousandrei', cursor: cursor }, function (err, obj, res) {
		if (err)
			return callback(err)

		cursor = JSON.parse(res.body).next_cursor
		console.log(obj)
		for (let u of obj.users)
			web.users[u.id] = u

		callback()
	})
}, (err) => {
	if (err)
		console.log(err)

	console.log(web)
})
