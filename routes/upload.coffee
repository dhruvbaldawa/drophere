service = require '../lib/service'
fs = require 'fs'

is_valid: (file) =>
    MAX_UPLOAD_SIZE = 5 * 1024*1024
    # @TODO (DB): change the mimetypes to regexes
    ALLOWED_TYPES = 'text/.*|image/.*'

    if file.type.match(ALLOWED_TYPES) and file.size <= MAX_UPLOAD_SIZE
        return true
    else
        return false

exports.upload = (req, res) ->
    file = req.files.file

    if not is_valid(file)
        resp =
            error: true
            filename: file.name
            message: 'Currently only text and image files less than 5MB are supported'
        res.send resp


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
