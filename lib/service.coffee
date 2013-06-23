config = require('./config')
request = require('request')

class exports.PastebinService
    constructor: (@file) ->
        # file is an object with the following parameters
        #  - name
        #  - size
        #  - type
        #  - data
        #  - lastModifiedDate

    dispatch: =>
        # request data
        send_params =
            api_dev_key: config.pastebin.api_key
            api_option: 'paste'
            api_paste_code: @file.data
            api_paste_name: @file.name
            api_paste_private: 1

        request_params =
            method: 'POST'
            uri: config.pastebin.url
            form: send_params

        request request_params, (error, response, body) ->
            if not error and response.statusCode == 200
                return body
