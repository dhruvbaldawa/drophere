app = require '../app.js'
Browser = require 'zombie'
chai = require 'chai'
should = chai.should()
global = {}

# start the server application
app.set('env', 'testing')
app.listen 3000

describe "Web Client UI", ->
    browser = new Browser({site: 'http://localhost:3000'})
    after = () =>
        browser.close()
        app.close()

    it "check if browser is defined", () ->
        browser.should.not.equal undefined
