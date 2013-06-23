class BaseHandler
    constructor: (@file, @progress_bar, @error_element) ->

    read: ->
        reader = new FileReader
        reader.onerror = @error_handler
        reader.onprogress = @update_progress

        reader.onabort = (evt) =>
            alert 'File reading aborted !'

        reader.onloadstart = (evt) =>
            console.log 'Loading'
            @progress_bar.html 'Loading'

        reader.onload = (evt) =>
            console.log 'Loaded'
            @progress_bar.html 'Loaded'

        reader.readAsText @file

    error_handler: (evt) ->
        switch evt.target.error.code
            when evt.target.error.NOT_FOUND_ERR then alert 'File Not Found.'
            when evt.target.error.NOT_READABLE_ERR then alert 'File is not readable.'
            when evt.target.error.ABORT_ERR then null
            else alert 'An error occurred reading this file.'

    update_progress: (evt) ->
        if evt.lengthComputable
            percent_loaded = Math.round (evt.loaded / evt.total) * 100

            if percent_loaded < 100
                console.log '#{percent_loaded}%'
                @progress_bar.html "#{percent_loaded}%"

    upload: ->


handle_drag_over = (evt) ->
    evt.stopPropagation()
    evt.preventDefault()
    evt.originalEvent.dataTransfer.dropEffect = 'copy'


handle_drop = (evt) ->
    evt.stopPropagation();
    evt.preventDefault();
    window.data = evt.originalEvent.dataTransfer
    files = evt.originalEvent.dataTransfer.files
    console.log files

    for file in files
        _progress_bar = document.createElement 'div'
        _error_element = document.createElement 'div'

        progress_bar = $(_progress_bar)
        error_element = $(_error_element)

        $('#output').append progress_bar
        $('#output').append error_element

        handler = new BaseHandler file, progress_bar, error_element
        handler.read()


window.onload = () ->
    # Check for the various File API support.
    if not (window.File and window.FileReader and window.FileList and window.Blob)
        alert('APIs are not supported')
        # @TODO (DB): better error handling here.
        null

    drop_zone = $('#drop-zone')
    drop_zone.bind 'dragover', handle_drag_over
    drop_zone.bind 'drop', handle_drop
