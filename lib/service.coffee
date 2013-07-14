config = require('./config')
request = require('request')
fs = require('fs')


class Service
    constructor: ->
    _handle_body: (body) ->
    dispatch: (file, callback) ->
        # contacts the API and gets the response after the creation of the entity.
        # after the entity is created and uploaded, the callback is called with
        # the following parameters:
        #     error -> (boolean) if there was an error or not
        #     filename -> (string) name of the file
        #     url -> (string) the URL of the uploaded file
        #     message -> (string) some extra additional message to be provided

class PastebinService extends Service
    dispatch: (file, callback) ->
        # get file data
        data = fs.readFileSync(file.path, "utf-8")
        send_params =
            api_dev_key: config.pastebin.api_key
            api_option: 'paste'
            api_paste_code: data
            api_paste_name: file.name
            api_paste_private: 1

        request_params =
            method: 'POST'
            uri: config.pastebin.api_url
            form: send_params

        request request_params, (error, response, body) ->
            [url, message] = [null, null]
            if error or response.statusCode != 200
                message = body
                error = true
            else
                error = false
                url = body

            callback error, file.name, url, message

class ImgurService extends Service
    dispatch: (file, callback) ->
        data = fs.readFileSync(file.path, "base64")
        send_params =
            image: data
            title: file.name

        request_params =
            method: 'POST'
            uri: config.imgur.api_url
            form: send_params
            headers:
                Authorization: "Client-ID #{config.imgur.api_client_id}"

        # @TODO (DB): fold this into base model.
        # @TODO (DB): error handling
        request request_params, (error, response, body) ->
            [url, message] = [null, null]
            if error or response.statusCode != 200
                message = body
                error = true
            else
                link = JSON.parse(body).data.link
                url = link
                error = false

            callback error, file.name, url, message

exports.PastebinService = PastebinService
exports.ImgurService = ImgurService
