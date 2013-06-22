console.log 'started'

handle_drag_over = (evt) ->
    evt.stopPropagation()
    evt.preventDefault()
    evt.dataTransfer.dropEffect = 'copy'


handle_drop = (evt) ->
    evt.stopPropagation();
    evt.preventDefault();
    console.log evt.dataTransfer.files

    output = $('#output')

    for file in evt.dataTransfer.files
        str = "Filename: #{file.name}"
        output.append(str)


window.onload = () ->
    drop_zone = document.getElementById('drop-zone')
    drop_zone.addEventListener 'dragover', handle_drag_over, false
    drop_zone.addEventListener 'drop', handle_drop, false
