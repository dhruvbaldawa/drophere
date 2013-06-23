# global namespace
root = exports ? this

class BaseDispatcher
    constructor: (@file, @progress_bar, @error_element) ->
        @reader = new FileReader
        @reader.onerror = @error_handler
        @reader.onprogress = @update_progress

        @reader.onabort = (evt) =>
            alert 'File reading aborted !'

        @reader.onloadstart = (evt) =>
            console.log 'Loading'
            @progress_bar.html 'Loading'

        @reader.onload = (evt) =>
            console.log 'Loaded'
            @progress_bar.html 'Loaded'

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

    dispatch: ->

class PasteBinDispatcher extends BaseDispatcher
    dispatch: =>
        @reader.readAsText @file
        root.reader = @reader
        # request data
        send_params =
            api_dev_key: config.pastebin.api_key
            api_option: 'paste'
            api_paste_code: @reader.result
            api_paste_name: @file.name
            api_paste_private: 1

        ajax_params =
            type: 'POST'
            url: config.pastebin.url
            data: send_params
            dataType: 'text'
            progress: @update_progress
            success: (data) =>
                console.log data

        $.ajax ajax_params

handle_drag_over = (evt) ->
    evt.stopPropagation()
    evt.preventDefault()
    evt.originalEvent.dataTransfer.dropEffect = 'copy'

handle_drop = (evt) ->
    evt.stopPropagation();
    evt.preventDefault();
    drop_zone.removeClass('drag-active')
    files = evt.originalEvent.dataTransfer.files
    console.log files

    for file in files
        _progress_bar = document.createElement 'div'
        _error_element = document.createElement 'div'

        progress_bar = $(_progress_bar)
        error_element = $(_error_element)

        $('#output').append progress_bar
        $('#output').append error_element

        dispatcher = new PasteBinDispatcher file, progress_bar, error_element
        dispatcher.dispatch()

handle_drag_enter = (evt) ->
    evt.stopPropagation()
    evt.preventDefault()
    console.log 'enter'
    drop_zone.addClass('drag-active')

handle_drag_leave = (evt) ->
    evt.stopPropagation()
    evt.preventDefault()
    console.log 'leave'
    # only change when dragleaves the drop_mask, otherwise the evt
    # is also triggered when it enters any of the children elements of
    # drop_zone
    if evt.srcElement is drop_mask.get(0)
        console.log evt
        drop_zone.removeClass('drag-active')

window.onready = () ->
    # Check for the various File API support.
    if not (window.File and window.FileReader and window.FileList and window.Blob)
        alert('APIs are not supported')
        # @TODO (DB): better error handling here.
        null

    root.drop_zone = $("#drop-zone")
    root.drop_mask = $("#drop-zone #drop-mask")

    # binding events
    drop_zone.bind 'dragenter', handle_drag_enter
    drop_zone.bind 'dragleave', handle_drag_leave
    drop_zone.bind 'dragover', handle_drag_over
    drop_zone.bind 'drop', handle_drop
