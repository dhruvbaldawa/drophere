app = require('../app.js')
Browser = require('zombie')
chai = require('chai')
sinon = require('sinon')
expect = chai.expect
fs = require('fs')
sys = require('sys')

before(() ->
    # start the server application
    app.set('env', 'testing')
    app.listen 3000
)

describe "Front-end", ->
    browser = null
    overlay_cls = ".drag-active"
    ajax = null
    $ = null

    # mock file drop event object
    mock_drop_evt =
        originalEvent:
            dataTransfer:
                files: [
                    name: 'sample_file'
                    type: 'text/plain'
                    size: 100
                ]
        stopPropagation: () -> null
        preventDefault: () -> null

    stub_ajax = (browser) ->
        stub = sinon.stub(browser.window.jQuery, 'ajax')

    beforeEach((done) ->
        browser = new Browser({site: 'http://localhost:3000'})
        browser.visit("/")
        .then () ->
            ajax = stub_ajax browser
            # hack to add missing FormData class inside the browser
            browser.window._evaluate fs.readFileSync(fs.realpathSync('.') + '/test/form_data.js', 'utf8')
            $ = browser.window.jQuery
            done()
        .fail (error) ->
            done(error)
    )

    afterEach((done) ->
        browser.close()
        ajax.restore()
        done()
    )

    after = () ->
        browser.close()
        app.close()

    it "should check if browser is defined", () ->
        expect(browser).to.be.ok


    it "should check if overlay is displayed on drag over", (done) ->
        browser.fire("body", 'dragenter')
        .then () =>
            overlay = browser.query overlay_cls
            expect(overlay).to.exist
            done()
        .fail (error) =>
            done(error)


    it "should check if overlay is hidden on drag leave", (done) ->
        browser.fire("#drop-mask", 'dragleave')
        .then () =>
            overlay = browser.query overlay_cls
            expect(overlay).to.not.exist
            done()
        .fail (error) =>
            done(error)


    it "should check if dropping file adds the DOM element", () ->
        # mock the jQuery behaviour
        ajax
        .yieldsTo "success",
            error: false
            message: 'message'
            url: 'http://some.url'
            filename: 'some-file'


        # mock the drop event
        browser.window.handle_drop mock_drop_evt
        file_el = $(".file")
        progressbar = $(".file .progress-bar")
        message = $(".file .message")

        # file element is present
        expect(file_el).to.have.length.above(0)
        # progress bar is present
        expect(progressbar).to.have.length.above(0)
        # message is present
        expect(message).to.have.length.above(0)


    it "should check if URL is shown on successful upload", () ->
        ajax
        .yieldsTo "success",
            error: false
            message: 'some message'
            url: 'http://file.url/file'
            filename: 'file'

        browser.window.handle_drop mock_drop_evt
        # progress bar is inactive
        expect($('.active')).to.have.length(0)
        # progress bar should show success
        expect($('.progress-success')).to.have.length.above(0)

        # text should show success
        expect($('.text-success')).to.have.length.above(0)
        # text should show URL
        expect($('.text-success > a').get(0).href).to.equal('http://file.url/file')


    it "should check message when upload is in progress", () ->
        ajax
        .yieldsTo "progress",
            lengthComputable: true
            loaded: 50
            total: 100

        browser.window.handle_drop mock_drop_evt
        # progress bar is active
        expect($('.active')).to.have.length.above(0)

        # text should show info
        expect($('.text-info')).to.have.length.above(0)


    it "should check if error message is shown on unsuccessful upload", () ->
        ajax
        .yieldsTo "success",
            error: true
            message: 'error'
            url: ''
            filename: 'file'

        browser.window.handle_drop mock_drop_evt
        # progress bar is inactive
        expect($('.active')).to.have.length(0)
        # progress bar should show danger
        expect($('.progress-danger')).to.have.length.above(0)

        # text should show error
        expect($('.text-error')).to.have.length.above(0)
        # text should show the message
        expect($('.text-error').html()).to.equal('error')


    it "should not upload file of invalid type", () ->
        file =
            name: 'sample_file'
            type: 'application/pdf'
            size: 100
        mock_drop_evt.originalEvent.dataTransfer.files[0] = file

        browser.window.handle_drop mock_drop_evt
        # text should show error
        expect($('.text-error')).to.have.length.above(0)


    it "should not upload file greater than maximum allowed size", () ->
        file =
            name: 'sample_file'
            type: 'text/plain'
            size: 10*1024*1024

        mock_drop_evt.originalEvent.dataTransfer.files[0] = file

        browser.window.handle_drop mock_drop_evt
        # text should show error
        expect($('.text-error')).to.have.length.above(0)
