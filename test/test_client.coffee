app = require '../app.js'
Browser = require 'zombie'
chai = require 'chai'
should = chai.should()
expect = chai.expect
globals = {}

# start the server application
app.set('env', 'testing')
app.listen 3000

describe "Web Client UI", ->
    browser = new Browser({site: 'http://localhost:3000'})
    overlay_cls = ".drag-active"

    after = () ->
        browser.close()
        app.close()

    it "check if browser is defined", () ->
        expect(browser).to.be.ok

    it "check if overlay is displayed on drag over", (done) ->
        browser.visit("/")
        .then () =>
            browser.fire("body", 'dragenter')
            .then () =>
                overlay = browser.query overlay_cls
                expect(overlay).to.exist
                done()
            .fail (error) =>
                done(error)
        .fail (error) ->
            done(error)
        null

    it "check if overlay is hidden on drag leave", (done) ->
        browser.visit("/")
        .then () =>
            debugger
            browser.fire("#drop-mask", 'dragleave')
            .then () =>
                overlay = browser.query overlay_cls
                expect(overlay).to.not.exist
                done()
            .fail (error) =>
                done(error)
        .fail (error) ->
            done(error)
        null
