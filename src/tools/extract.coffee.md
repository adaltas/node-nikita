
# `nikita.tools.extract(options, [callback])`

Extract an archive. Multiple compression types are supported. Unless
specified as an option, format is derived from the source extension. At the
moment, supported extensions are '.tgz', '.tar.gz', tar.bz2, 'tar.xz' and '.zip'.

## Options

* `creates`   
  Ensure the given file is created or an error is send in the callback.  
* `format`   
  One of 'tgz', 'tar', 'xz', 'bz2' or 'zip'.   
* `preserve_owner`   
  Preserve ownership when extracting. True by default if runned as root, else false.   
* `preserve_permissions`   
  Preserve permissions when extracting. True by default if runned as root, else false.   
* `source`   
  Archive to decompress.   
* `strip`   
  Remove the specified number of leading path elements. Apply only to tar(s) formats.   
* `target`   
  Default to the source parent directory.   

## Callback parameters

* `err`   
  Error object if any.   
* `extracted`   
  Value is "true" if archive was extracted.   

## Example

```javascript
require('nikita').tools.extract({
  source: '/path/to/file.tgz'
  destation: '/tmp'
}, function(err, status){
  console.log(err ? err.message : 'File was extracted: ' + status);
});
```

## Source Code

    module.exports = (options, callback) ->
      options.log message: "Entering extract", level: 'DEBUG', module: 'nikita/lib/tools/extract'
      # SSH connection
      ssh = @ssh options.ssh
      # Validate options
      return callback Error "Missing source: #{options.source}" unless options.source
      target = options.target ? path.dirname options.source
      tar_opts = []
      # If undefined, we do not apply flag. Default behaviour depends on the user
      if options.preserve_owner is true
        tar_opts.push '--same-owner'
      else if options.preserve_owner is false
        tar_opts.push '--no-same-owner'
      if options.preserve_permissions is true
        tar_opts.push '-p'
      else if options.preserve_permissions is false
        tar_opts.push '--no-same-permissions'
      if typeof options.strip is 'number'
        tar_opts.push "--strip-components #{options.strip}"
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
        fs.stat ssh, options.source, (err, stat) ->
          return callback Error "File does not exist: #{options.source}" if err
          return callback Error "Not a File: #{options.source}" unless stat.isFile()
          extract()
      extract = () =>
        cmd = null
        options.log message: "Format is #{format}", level: 'DEBUG', module: 'nikita/lib/tools/extract'
        switch format
          when 'tgz' then cmd = "tar xzf #{options.source} -C #{target} #{tar_opts.join ' '}"
          when 'tar' then cmd = "tar xf #{options.source} -C #{target} #{tar_opts.join ' '}"
          when 'bz2' then cmd = "tar xjf #{options.source} -C #{target} #{tar_opts.join ' '}"
          when 'xz'  then cmd = "tar xJf #{options.source} -C #{target} #{tar_opts.join ' '}"
          when 'zip' then cmd = "unzip -u #{options.source} -d #{target}"
        @system.execute
          cmd: cmd
        , (err, created) ->
          return callback err if err
          creates()
      # Step for `creates`
      creates = () ->
        return success() unless options.creates?
        fs.exists ssh, options.creates, (err, exists) ->
          return callback Error "Failed to create '#{path.basename options.creates}'" unless exists
          success()
      # Final step
      success = () ->
        callback null, true
      stat()

## Dependencies

    fs = require 'ssh2-fs'
    path = require 'path'
