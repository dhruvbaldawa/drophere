# global namespace
root = exports ? this

class Uploader
    constructor: (@file, @progress_bar, @message) ->
        @_bar = @progress_bar.find('.bar')

    error_handler: (evt) ->
        switch evt.target.error.code
            when evt.target.error.NOT_FOUND_ERR then alert 'File Not Found.'
            when evt.target.error.NOT_READABLE_ERR then alert 'File is not readable.'
            when evt.target.error.ABORT_ERR then null
            else alert 'An error occurred reading this file.'

    _update_progress_bar: (percent) ->
        @_bar.width "#{percent}%"

    update_progress: (evt) =>
        if evt.lengthComputable
            percent_loaded = Math.round (evt.loaded / evt.total) * 100

            if percent_loaded < 100
                console.log "#{percent_loaded}%"
                @_update_progress_bar percent_loaded

    upload_complete: (data) =>
        @_update_progress_bar 100
        console.log data
        @progress_bar.removeClass('active')

    upload: ->
        form_data = new FormData
        form_data.append @file.name, @file

        ajax_params =
            type: 'POST'
            url: '/upload'
            data: form_data
            contentType: false
            processData: false

            progress: @update_progress
            success: @upload_complete

        $.ajax ajax_params
        null

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
        root.file = file
        file.id = new Date().getTime() # if same file is added twice.
        file_html = "
        <div id=\"file-#{file.name}-#{file.id}\" class=\"file media\">
            <div class=\"media-body\">
                <h4 class=\"media-heading\">#{file.name}</h4>
                <div class=\"message pull-left\">Some message</div>
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
    if not (window.File and window.FileReader and window.FileList and window.Blob and window.FormData)
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
