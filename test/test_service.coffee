service = require('../lib/service.js')
config = require('../lib/config.js')
chai = require('chai')
nock = require('nock')
sys = require('sys')
expect = chai.expect


file = null
pastebin = null
imgur = null

beforeEach (done) ->
    pastebin = nock('http://pastebin.com')

    imgur = nock('https://api.imgur.com')

    file =
        name: 'test_file'
        path: __filename
        size: 10
        type: 'text/plain'
    done()


describe 'Pastebin service', () ->
    pb = null
    before (done) ->
        pb = new service.PastebinService()
        done()

    it 'should work fine on success response', (done) ->
        pastebin.post('/api/api_post.php')
            .reply(200, 'message')

        cb = (error, file, url, message) ->
            expect(error).to.be.false
            expect(file).to.be.ok
            expect(url).to.be.ok
            done()

        pb.dispatch(file, cb)

    it 'should return error on error response', (done) ->
        pastebin.post('/api/api_post.php')
            .reply(500)

        cb = (error, file, url, message) ->
            expect(error).to.be.true
            expect(file).to.be.ok
            expect(url).to.not.exist
            done()

        pb.dispatch(file, cb)

describe 'Imgur service', () ->
    im = null
    before (done) ->
        im = new service.ImgurService()
        done()

    it 'should work fine on success response', (done) ->
        imgur.post('/3/image')
            .reply(200, {'data': {'link': 'http://some.link'}})

        cb = (error, file, url, message) ->
            expect(error).to.be.false
            expect(file).to.be.ok
            expect(url).to.be.ok
            done()

        im.dispatch(file, cb)


    it 'should return error on error response', (done) ->
        imgur.post('/3/image')
            .reply(500)

        cb = (error, file, url, message) ->
            expect(error).to.be.true
            expect(file).to.be.ok
            expect(url).to.not.exist
            done()

        im.dispatch(file, cb)
