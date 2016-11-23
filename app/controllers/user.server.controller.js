const User = require('mongoose').model('User')

exports.get = (req, res) => {
	User.find(req.query, (err, result) => {
		/* istanbul ignore if  */
		if (err)
			return res.status(500).json(err)
		else
			return res.json(result)
	})
}

exports.getOne = (req, res) => {
	User.find(req.params.id, (err, result) => {
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
	new User(req.body).save((err, result) => {
		/* istanbul ignore if  */
		if (err)
			return res.status(500).json(err)
		else
			return res.json(result)
	})
}

exports.patch = (req, res) => {
	User.findOneAndUpdate(req.params,
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
	User.findOneAndUpdate(req.params,
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
	User.findByIdAndUpdate(req.params,
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