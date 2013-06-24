service = require '../lib/service'
fs = require 'fs'

exports.upload = (req, res) ->
    debugger
    for filename, file of req.files
        fs.readFile file.path, {encoding: 'utf-8'},(err, data) ->
            file =
                data: data
                name: file.name
                size: file.size
                type: file.type
            # s = new service.PastebinService
            # ret_val = s.dispatch file, (error, filename, url, message) ->
            #         resp =
            #             error: error
            #             filename: filename
            #             url: url
            #             message: message
            #         res.send resp
            console.log file
            res.send file
