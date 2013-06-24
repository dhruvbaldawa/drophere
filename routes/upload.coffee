service = require '../lib/service'
fs = require 'fs'

exports.upload = (req, res) ->
    file = req.files.file

    [type, subtype] = file.type.split("/", 1)

    if type is 'image'
        s = new service.ImgurService
    else
        s = new service.PastebinService

    ret_val = s.dispatch file, (error, filename, url, message) ->
            resp =
                error: error
                filename: filename
                url: url
                message: message
            res.send resp
