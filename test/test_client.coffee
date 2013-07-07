app = require '../app.js'
Browser = require 'zombie'
chai = require 'chai'
sinon = require 'sinon'
expect = chai.expect
fs = require 'fs'
sys = require 'sys'

# start the server application
app.set('env', 'testing')
app.listen 3000

describe "Drag overlay", ->
    browser = new Browser({site: 'http://localhost:3000'})
    overlay_cls = ".drag-active"
    # mock file drop event object
    mock_evt =
        originalEvent:
            dataTransfer:
                files: [
                    name: 'sample_file'
                    type: 'text/plain'
                    size: 100
                ]
        stopPropagation: () -> null
        preventDefault: () -> null

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

    it "check if dropping file adds the DOM element", (done) ->
        browser.visit("/")
        .then () =>
            # hack to add missing FormData class inside the browser
            browser.window._evaluate fs.readFileSync(fs.realpathSync('.') + '/test/form_data.js', 'utf8')

            # mock the drop event
            browser.window.handle_drop mock_evt
            file_el = browser.query ".file"
            progressbar = browser.query ".file .progress-bar"
            message = browser.query ".file .message"

            # assertions
            expect(file_el).to.exist
            expect(progressbar).to.exist
            expect(message).to.exist
            done()
        .fail (error) ->
            done(error)
        null
