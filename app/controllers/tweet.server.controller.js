const Tweet = require('mongoose').model('Tweet')

exports.get = (req, res) => {
	Tweet.find(req.query, (err, result) => {
		/* istanbul ignore if  */
		if (err)
			return res.status(500).json(err)
		else
			return res.json(result)
	})
}

exports.getOne = (req, res) => {
	Tweet.find(req.params.id, (err, result) => {
		/* istanbul ignore if  */
		if (err)
			return res.status(500).json(err)
		else if (result.length > 0)
			return res.json(result[0])
		else
			return res.status(404).end()
	})
}

exports.post = (req, res) => {
	new Tweet(req.body).save((err, result) => {
		/* istanbul ignore if  */
		if (err)
			return res.status(500).json(err)
		else
			return res.json(result)
	})
}

exports.patch = (req, res) => {
	Tweet.findOneAndUpdate(req.params,
		req.body, {
			new: true
		}, (err, result) => {
			/* istanbul ignore if  */
			if (err)
				return res.status(500).json(err)
			else
				return res.json(result)
		})
}

exports.put = (req, res) => {
	Tweet.findOneAndUpdate(req.params,
		req.body, {
			new: true
		}, (err, result) => {
			/* istanbul ignore if  */
			if (err)
				return res.status(500).json(err)
			else
				return res.json(result)
		})
}

exports.delete = (req, res) => {
	Tweet.findByIdAndUpdate(req.params,
		{
			deleted: true
		}, (err, result) => {
			/* istanbul ignore if  */
			if (err)
				return res.status(500).json(err)
			else
				return res.json(result)
		})
}