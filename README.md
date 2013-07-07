drophere
========

A small drag-and-drop file uploader I created which uses the file type to upload it to relevant file-hosting service.
Text files are uploaded to Pastebin and Image files to Imgur.
I created this to play with CoffeeScript, Node.js, Express.js and HTML5 Drag and Drop

If you are looking for code, the main files to look at are:
 * lib/service.coffee
 * public/bootstrap/js/script.coffee
 * routes/upload.coffee
 
I wish to make it for robust for now, and add tests. Any help/suggestions for those will be helpful :)
and then add few more services, and support more file types.

ToDo
----
 - [] Display messages/errors to the user depending on server-side response.
 - [] Write error checking code for external API requests
 - [] Write tests !
