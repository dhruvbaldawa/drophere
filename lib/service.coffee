config = require('./config')
request = require('request')


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
    constructor: ->
        # file is an object with the following parameters
        #  - name
        #  - size
        #  - type
        #  - data
        #  - mtime

    dispatch: (file, callback) ->
        # request data
        send_params =
            api_dev_key: config.pastebin.api_key
            api_option: 'paste'
            api_paste_code: file.data
            api_paste_name: file.name
            api_paste_private: 1

        request_params =
            method: 'POST'
            uri: config.pastebin.url
            form: send_params

        request request_params, (error, response, body) ->
            [url, message] = [null, null]
            if error or response.statusCode != 200
                message = body
            else
                url = body

            callback error, file.name, url, message

exports.PastebinService = PastebinService
