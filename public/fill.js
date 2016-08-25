/* globals $ vis document io */

let socket = io.connect('https://localhost')

let network

let web = {}
web.nodes = new vis.DataSet([])
web.edges = new vis.DataSet([])

socket.on('node', (data) => {
	console.log('New Node')
	web.nodes.add(data)
})

socket.on('edge', (data) => {
	console.log('New Edge')
	web.edges.add(data)
})

socket.on('connect', function () {
	console.log('Connected')

	let container = document.getElementById('web')

	let options = {
		edges: {
			arrows: {
				to: {
					enabled: true,
					scaleFactor: 0.5
				}
			},
		},
		nodes: {
			size: 50,
			title: 'e',
			shape: 'dot'
		},
		interaction: {
			hover: true,
		}
	}

	network = new vis.Network(container, web, options)
})