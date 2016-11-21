/*eslint-env mocha */
process.env.NODE_ENV = 'test'

const App = require('../index.js')
const Supertest = require('supertest')
const {HTTP} = require('../config/config')


describe('servidor', () => {
	before(() => { })


	after(() => { })


	it('porta 80 online', (done) => {
		Supertest('http://127.0.0.1:' + HTTP)
			.get('/')
			.end((err) => {
				if (err)
					throw err

				done()
			})
	})

	it('porta 443 online', (done) => {
		Supertest(App)
			.get('/')
			.end((err) => {
				if (err)
					throw err

				done()
			})
	})

	describe('rotas UI', () => {

		it('redirect 80', function (done) {
			Supertest('http://127.0.0.1:' + HTTP)
				.get('/rotaAleatoria')
				.expect(302)
				.end((err) => {
					if (err)
						throw err

					done()
				})

		})
		it('unknown route', function (done) {
			Supertest(App)
				.get('/rotaAleatoria')
				.expect(404)
				.end((err) => {
					if (err)
						throw err

					done()
				})

		})

		it('unknown api route', function (done) {
			Supertest(App)
				.get('/api/rotaAleatoria')
				.expect(404)
				.end((err) => {
					if (err)
						throw err

					done()
				})

		})

		it('page', function (done) {
			Supertest(App)
				.get('/')
				.expect(200)
				.end((err) => {
					if (err)
						throw err

					done()
				})
		})

	})
})
