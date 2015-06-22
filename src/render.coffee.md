
# `render(options, callback)`

Render a template file. The following templating engines are
integrated. More are added on demand.      

*   [ECO](http://github.com/sstephenson/eco) (default)   
*   [Nunjucks](http://mozilla.github.io/nunjucks/) ("*.j2")   

## Options

*   `engine`   
    Template engine to use, default to "eco".   
*   `content`   
    Templated content, bypassed if source is provided.   
*   `source`   
    File path where to extract content from.   
*   `destination`   
    File path where to write content to or a callback.   
*   `context`   
    Map of key values to inject into the template.   
*   `local_source`   
    Treat the source as local instead of remote, only apply with "ssh"
    option.   
*   `skip_empty_lines`   
    Remove empty lines.   
*   `uid`   
    File user name or user id.   
*   `gid`   
    File group name or group id.   
*   `mode`   
    File mode (permission and sticky bits), default to `0666`, in the for of
    `{mode: 0o744}` or `{mode: "744"}`.   
*   `ssh` (object|ssh2)   
    Run the action on a remote server using SSH, an ssh2 instance or an
    configuration object used to initialize the SSH connection.   
*   `stdout` (stream.Writable)   
    Writable EventEmitter in which the standard output of executed commands will
    be piped.   
*   `stderr` (stream.Writable)   
    Writable EventEmitter in which the standard error output of executed command
    will be piped.   

If destination is a callback, it will be called with the generated content as
its first argument.   

## Callback parameters

*   `err`   
    Error object if any.   
*   `rendered`   
    Number of rendered files.   

## Rendering with Nunjucks

```js
require('mecano').render({
  source: './some/a_template.j2',
  destination: '/tmp/a_file',
  context: {
    username: 'a_user'
  }
}, function(err, rendered){
  console.log(err ? err.message : 'File rendered: ' + !!rendered);
});
```

## Source Code

    module.exports = (options, callback) ->
      # Validate parameters
      return callback new Error 'Missing source or content' unless options.source or options.content
      return callback new Error 'Missing destination' unless options.destination
      # Start real work
      do_read_source = ->
        return do_write() unless options.source
        ssh = if options.local_source then null else options.ssh
        fs.exists ssh, options.source, (err, exists) ->
          return callback new Error "Invalid source, got #{JSON.stringify(options.source)}" unless exists
          fs.readFile ssh, options.source, 'utf8', (err, content) ->
            return callback err if err
            options.content = content
            do_write()
      do_write = =>
        if not options.engine and options.source
          extension = path.extname options.source
          options.engine = 'nunjunks' if extension is '.j2'
        options.source = null
        @write(options).then callback
      do_read_source()

## Dependencies

    fs = require 'ssh2-fs'
    path = require 'path'






