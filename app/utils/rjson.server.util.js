const {execSync, spawnSync} = require('child_process')
const fs = require('fs')

let net = execSync('rscript app/lib/r/filtered-tweet.lib.r --word=trump').toString()

net = JSON.stringify(JSON.parse(net), null, 2)

fs.writeFile('/porra.json', net, function(err) {
	if (err) throw err
	
})