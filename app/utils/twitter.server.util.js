'use strict'

//Crawler pra twitter, 1 request p/ segundo
// function crawl(userName, next) {
// 	let page = 0
// 	let cursor = -1
// 	let followers = {}

// 	console.log('Crawling ' + userName)
// 	until(() => cursor == 0, (callback) => {
// 		client.get('friends/list', { screen_name: userName, cursor: cursor }, function (err, obj, res) {
// 			if (err)
// 				return callback(err)

// 			cursor = JSON.parse(res.body).next_cursor

// 			console.log(page)
// 			page++

// 			for (let u of obj.users)
// 				followers[u.id] = u

// 			setTimeout(callback, 60000)
// 		})
// 	}, (err) => {
// 		if (err)
// 			return console.log(err)

// 		writeFileSync('./files/' + userName + '.json', JSON.stringify(followers, null, 4))

// 		console.log('Crawled ' + userName)

// 		eachSeries(followers, (f, callback) => {
// 			try {
// 				return statSync('./files/' + f.screen_name + '.json')
// 			} catch (e) {
// 				if (e.code === 'ENOENT')
// 					setTimeout(() => crawl(f.screen_name, () => callback()), 60000)
// 			}
// 		}, () => {
// 			next()
// 		})

// 	})
// }

// crawl('sousandrei', () => console.log('end'))