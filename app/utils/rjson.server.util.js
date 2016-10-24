const {exec} = require('child_process')

let json = {
	'nodes': [
		{
			'a': 0,
			'b': 1
		}
	],
	'edges': [
		{
			'a': 0,
			'b': 1
		}
	]
}

exec(`echo ${JSON.stringify(json)} | rscript app/lib/teste.lib.r`, (error, stdout, stderr) => {
	if (error) return console.error(`exec error: ${error}`)
	// if (stderr) return console.log(stderr)

	console.log(JSON.stringify(JSON.parse(stdout), null, 2))
})
