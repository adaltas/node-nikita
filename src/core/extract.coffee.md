
# `extract(options, callback)`

Extract an archive. Multiple compression types are supported. Unless
specified as an option, format is derived from the source extension. At the
moment, supported extensions are '.tgz', '.tar.gz', tar.bz2, 'tar.xz' and '.zip'.

## Options

*   `source`   
    Archive to decompress.   
*   `destination`   
    Default to the source parent directory.   
*   `format`   
    One of 'tgz', 'tar', 'xz', 'bz2' or 'zip'.   
*   `creates`   
    Ensure the given file is created or an error is send in the callback.   
*   `unless_exists`   
    Cancel extraction if file exists.   
*   `ssh` (object|ssh2)   
    Run the action on a remote server using SSH, an ssh2 instance or an
    configuration object used to initialize the SSH connection.   
*   `stdout` (stream.Writable)   
    Writable EventEmitter in which the standard output of executed commands will
    be piped.   
*   `stderr` (stream.Writable)   
    Writable EventEmitter in which the standard error output of executed command
    will be piped.   

## Callback parameters

*   `err`   
    Error object if any.   
*   `extracted`   
    Number of extracted actions with modifications.   

## Example

```javascript
require('mecano').extract({
  source: '/path/to/file.tgz'
  destation: '/tmp'
}, function(err, extracted){
  console.log(err ? err.message : 'File was extracted: ' + extracted);
});
```

## Source Code

    module.exports = (options, callback) ->
      # Validate parameters
      return callback new Error "Missing source: #{options.source}" unless options.source
      destination = options.destination ? path.dirname options.source
      # Deal with format option
      if options.format?
        format = options.format
      else
        if /\.(tar\.gz|tgz)$/.test options.source
          format = 'tgz'
        else if /\.tar$/.test options.source
          format = 'tar'
        else if /\.zip$/.test options.source
          format = 'zip'
        else if /\.tar\.bz2$/.test options.source
          format = 'bz2'
        else if /\.tar\.xz$/.test options.source
          format = 'xz'
        else
          ext = path.extname options.source
          return callback Error "Unsupported extension, got #{JSON.stringify(ext)}"
      # Start real work
      stat = () ->
        fs.stat options.ssh, options.source, (err, stat) ->
          return callback Error "File does not exist: #{options.source}" if err
          return callback Error "Not a File: #{options.source}" unless stat.isFile()
          extract()
      extract = () =>
        cmd = null
        options.log message: "Format is #{format}", level: 'DEBUG', module: 'mecano/src/extract'
        switch format
          when 'tgz' then cmd = "tar xzf #{options.source} -C #{destination}"
          when 'tar' then cmd = "tar xf #{options.source} -C #{destination}"
          when 'bz2' then cmd = "tar xjf #{options.source} -C #{destination}"
          when 'xz'  then cmd = "tar xJf #{options.source} -C #{destination}"
          when 'zip' then cmd = "unzip -u #{options.source} -d #{destination}"
        @execute
          cmd: cmd
        , (err, created) ->
          return callback err if err
          creates()
      # Step for `creates`
      creates = () ->
        return success() unless options.creates?
        fs.exists options.ssh, options.creates, (err, exists) ->
          return callback new Error "Failed to create '#{path.basename options.creates}'" unless exists
          success()
      # Final step
      success = () ->
        callback null, true
      stat()

## Dependencies

    fs = require 'ssh2-fs'
    path = require 'path'
