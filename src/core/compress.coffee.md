
# `compress(options, callback)`

Compress an archive. Multiple compression types are supported. Unless
specified as an option, format is derived from the source extension. At the
moment, supported extensions are '.tgz', '.tar.gz', 'tar.xz', 'tar.bz2' and '.zip'.

## Options

*   `source`   
    Archive to compress.   
*   `target`   
    Default to the source parent directory.   
*   `format`   
    One of 'tgz', 'tar', 'xz', 'bz2' or 'zip'.   
*   `creates`   
    Ensure the given file is created or an error is send in the callback.   
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
*   `compressed`
    Number of compressed actions with modifications.

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
      options.log message: "Entering compress", level: 'DEBUG', module: 'mecano/lib/compress'
      # Validate parameters
      return callback new Error "Missing source: #{options.source}" unless options.source
      return callback new Error "Missing target: #{options.target}" unless options.target
      options.source = path.normalize options.source
      options.target = path.normalize options.target
      dir = path.dirname options.source
      name = path.basename options.source
      # Deal with format option
      if options.format?
        format = options.format
      else
        if /\.(tar\.gz|tgz)$/.test options.target
          format = 'tgz'
        else if /\.tar$/.test options.target
          format = 'tar'
        else if /\.zip$/.test options.target
          format = 'zip'
        else if /\.bz2$/.test options.target
          format = 'bz2'
        else if /\.xz$/.test options.target
          format = 'xz'
        else
          ext = path.extname options.source
          return callback Error "Unsupported extension, got #{JSON.stringify(ext)}"
      cmd = null
      switch format
        when 'tgz' then cmd = "tar czf #{options.target} -C #{dir} #{name}"
        when 'tar' then cmd = "tar cf  #{options.target} -C #{dir} #{name}"
        when 'bz2' then cmd = "tar cjf #{options.target} -C #{dir} #{name}"
        when 'xz'  then cmd = "tar cJf #{options.target} -C #{dir} #{name}"
        when 'zip' then cmd = "(cd #{dir} && zip -r #{options.target} #{name} && cd -)"
      @execute
        cmd: cmd
      , (err, created) ->
        return callback err if err
        fs.exists options.ssh, options.target, (err, exists) ->
          return callback new Error "Failed to create '#{options.target}'" unless exists
          callback null, true

## Dependencies

    fs = require 'ssh2-fs'
    path = require 'path'
