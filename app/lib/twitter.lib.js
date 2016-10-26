'use strict'

const EventEmitter = require('events')
const {CONSUMER_KEY, CONSUMER_SECRET, ACCESS_TOKEN_KEY, ACCESS_TOKEN_SECRET} = require('../../config/config')
const {waterfall, eachSeries} = require('async')
const twitter = require('twitter')

const User = require('mongoose').model('User')
const Tweet = require('mongoose').model('Tweet')

exports.Twitter = class Twitter extends EventEmitter {
	constructor() {
		super()

		this.queue = []

		this.client = new twitter({
			consumer_key: CONSUMER_KEY,
			consumer_secret: CONSUMER_SECRET,
			access_token_key: ACCESS_TOKEN_KEY,
			access_token_secret: ACCESS_TOKEN_SECRET
		})
	}

	stopStream() {
		if (this.stream)
			this.stream.destroy()

		delete this.client
		clearInterval(this.interval)
	}

	startStream(a) {
		this.stream = this.client.stream('statuses/filter', { track: a })

		this.stream.on('data', (event) => this.queue.push(event))
		this.stream.on('error', (error) => { throw error })

		this.loop()
	}

	loop() {
		if (this.interval)
			return

		this.interval = setInterval(() => {
			let fila = this.queue
			this.queue = []

			eachSeries(fila, (f, callback) => {
				let t = f
				let u = t.user

				if (!u)
					return

				t.user = t.user.id

				return waterfall([
					(callback) => {
						this.createUser(u).then(callback)
					},
					(callback) => {
						return waterfall([
							(callback) => {
								if (!t.retweeted_status)
									return callback()

								this.createUser(t.retweeted_status.user).then(callback)
							},
							(callback) => {
								if (!t.retweeted_status)
									return callback()
								else
									t.retweeted_status.user = t.retweeted_status.user.id

								this.createTweet(t.retweeted_status).then(callback)
							},
							(callback) => {
								if (t.retweeted_status) t.retweeted_status = t.retweeted_status.id

								this.createTweet(t).then(callback)
							}
						], callback)
					}
				], () => {
					// console.log('@' + u.screen_name + ': ' + t.text)
					// console.log('=============================================')
					callback()
				})
			})
		}, 1000)
	}

	createUser(u) {
		return new Promise((resolve) => {
			User.findOne({ id: u.id }, (e, r) => {
				if (r)
					User.update({ id: u.id }, u, (e) => {
						if (e) throw (e)
						resolve()
					})
				else
					new User(u).save((e) => {
						if (e) throw (e)
						this.emit('newUser', u)
						resolve()
					})
			})
		})
	}

	createTweet(t) {
		return new Promise((resolve) => {

			Tweet.findOne({ id: t.id }, (e, r) => {
				if (r)
					Tweet.update({ id: t.id }, t, (e) => {
						if (e) throw (e)
						resolve()
					})
				else
					new Tweet(t).save((e) => {
						if (e) throw (e)
						this.emit('newTweet', t)
						resolve()
					})
			})
		})
	}

}
