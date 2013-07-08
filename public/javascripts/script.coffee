# global namespace
root = exports ? this

class Uploader
    constructor: (@file, @progress_bar, @message) ->
        @_bar = @progress_bar.find('.bar')

    error_handler: (evt) ->
        switch evt.target.error.code
            when evt.target.error.NOT_FOUND_ERR then @display_error 'File Not Found.'
            when evt.target.error.NOT_READABLE_ERR then @display_error 'File is not readable.'
            when evt.target.error.ABORT_ERR then null
            else @display_error 'An error occurred reading this file.'

    before_send: =>
        @progress_bar.addClass 'active'
        @display_info 'Uploading..'

    _update_progress_bar: (percent) ->
        @_bar.width "#{percent}%"

    _reset_message_classes: =>
        @message.removeClass 'text-info text-error text-class'

    _set_message: (type, message) =>
        @_reset_message_classes()
        @message.addClass "text-#{type}"
        @message.html message

    display_info: (message) =>
        @_set_message 'info', message

    display_error: (message) =>
        @_set_message 'error', message

    display_success: (message) =>
        @_set_message 'success', message

    is_valid: (file) =>
        MAX_UPLOAD_SIZE = 5 * 1024*1024
        # @TODO (DB): change the mimetypes to regexes
        ALLOWED_TYPES = ['text', 'image']
        [type, subtype] = file.type.split "/", 1

        if type in ALLOWED_TYPES and file.size <= MAX_UPLOAD_SIZE
            return true
        else
            return false

    update_progress: (evt) =>
        if evt.lengthComputable
            percent_loaded = Math.round (evt.loaded / evt.total) * 100

            if percent_loaded < 100
                @_update_progress_bar percent_loaded

            if percent_loaded > 99.99
                @display_info 'generating url..'
                @_update_progress_bar percent_loaded

    upload_complete: (data) =>
        @_update_progress_bar 100
        @progress_bar.removeClass 'active'

        if data.error
            @progress_bar.addClass 'progress-danger'
            @display_error data.message
        else
            @progress_bar.addClass 'progress-success'
            @display_success "<a href=\"#{data.url}\" target=\"_blank\">#{data.url}</a>"

    upload: ->
        if not @is_valid @file
            @display_error 'Only text and image files less than 5MB supported.'
            return

        form_data = new FormData()
        form_data.append 'file', @file

        @before_send()
        ajax_params =
            type: 'POST'
            url: '/upload'
            data: form_data
            contentType: false
            processData: false

            progress: @update_progress
            success: @upload_complete
            # @TODO (DB): write down an error handler

        $.ajax ajax_params
        null

##
## Events
##

_show_overlay = () ->
    drop_zone.show()
    drop_zone.addClass('drag-active')

_hide_overlay = () ->
    drop_zone.hide()
    drop_zone.removeClass('drag-active')

handle_drag_over = (evt) ->
    evt.stopPropagation()
    evt.preventDefault()
    evt.originalEvent.dataTransfer.dropEffect = 'copy'

handle_drop = (evt) ->
    evt.stopPropagation();
    evt.preventDefault();
    _hide_overlay()

    files = evt.originalEvent.dataTransfer.files
    for file in files
        file.id = new Date().getTime() # if same file is added twice.
        file_html = "
        <div id=\"file-#{file.name}-#{file.id}\" class=\"file media\">
            <div class=\"media-body\">
                <h4 class=\"media-heading\">#{file.name}</h4>
                <div class=\"message pull-left\"></div>
                <br>
                <div class=\"progress-bar progress progress-striped\">
                    <div class=\"bar\"></div>
                </div>
            </div>
        </div><hr>"

        $('#output').append(file_html)

        # hack because jQuery can't find the dynamically created element.
        file_el = document.getElementById "file-#{file.name}-#{file.id}"
        progress_bar = $(file_el).find '.progress-bar'
        message = $(file_el).find '.message'

        root.uploader = new Uploader file, progress_bar, message
        uploader.upload()

handle_drag_enter = (evt) ->
    evt.stopPropagation()
    evt.preventDefault()
    _show_overlay()

handle_drag_leave = (evt) ->
    evt.stopPropagation()
    evt.preventDefault()
    if evt.srcElement is drop_mask.get(0)
        console.log evt
        _hide_overlay()

window.onready = () ->
    # Check for the various File API support.
    if not (window.File and window.FileReader and window.FileList and window.Blob and window.FormData)
        alert('APIs are not supported')
        # @TODO (DB): better error handling here.
        null

    root.drop_zone = $("#drop-zone")
    root.drop_mask = $("#drop-zone #drop-mask")

    # binding events
    $(document).bind 'dragenter', handle_drag_enter
    $(document).bind 'dragleave', handle_drag_leave
    $(document).bind 'dragover', handle_drag_over
    drop_zone.bind 'drop', handle_drop
