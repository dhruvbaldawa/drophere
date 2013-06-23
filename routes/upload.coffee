service = require '../lib/service'

exports.upload = (req, res) ->
    file =
        name: 'test.txt'
        size: 12
        type: 'text/plain'
        data: 'Hello World'

    debugger

    s = new service.PastebinService file
    ret_val = s.dispatch()
    res.send "#{ret_val}"
