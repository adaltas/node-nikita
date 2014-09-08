
`extract([goptions], options, callback)`
----------------------------------------

Extract an archive. Multiple compression types are supported. Unless
specified as an option, format is derived from the source extension. At the
moment, supported extensions are '.tgz', '.tar.gz' and '.zip'.

## Options

*   `source`   
    Archive to decompress.   
*   `destination`   
    Default to the source parent directory.   
*   `format`   
    One of 'tgz', 'tar' or 'zip'.
*   `creates`   
    Ensure the given file is created or an error is send in the callback.   
*   `not_if_exists`   
    Cancel extraction if file exists.   
*   `ssh`   
    Run the action on a remote server using SSH, an ssh2 instance or an
    configuration object used to initialize the SSH connection.   

## Parameters

*   `err`   
    Error object if any.   
*   `extracted`   
    Number of extracted archives.   

## Example

```javascript
require('mecano').extract({
  source: '/path/to/file.tgz'
  destation: '/tmp'
}, function(err, extracted){
  console.log(err ? err.message : 'File was extracted: ' + extracted);
});
```

    module.exports = (goptions, options, callback) ->
      [goptions, options, callback] = misc.args arguments
      misc.options options, (err, options) ->
        return callback err if err
        extracted = 0
        each( options )
        .parallel(goptions.parallel)
        .on 'item', (options, next) ->
          options.log? "Mecano `extract`"
          # Validate parameters
          return next new Error "Missing source: #{options.source}" unless options.source
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
            else
              ext = path.extname options.source
              return next new Error "Unsupported extension, got #{JSON.stringify(ext)}"
          # Start real work
          extract = () ->
            cmd = null
            switch format
              when 'tgz' then cmd = "tar xzf #{options.source} -C #{destination}"
              when 'tar' then cmd = "tar xf #{options.source} -C #{destination}"
              when 'zip' then cmd = "unzip -u #{options.source} -d #{destination}"
            # exec cmd, (err, stdout, stderr) ->
            # options.cmd = cmd
            # exec options, (err, stdout, stderr) ->
            #   return next err if err
            #   creates()
            execute
              ssh: options.ssh
              cmd: cmd
              log: options.log
              stdout: options.stdout
              stderr: options.stderr
            , (err, created) ->
              return next err if err
              creates()
          # Step for `creates`
          creates = () ->
            return success() unless options.creates?
            fs.exists options.ssh, options.creates, (err, exists) ->
              return next new Error "Failed to create '#{path.basename options.creates}'" unless exists
              success()
          # Final step
          success = () ->
            extracted++
            next()
          # Run conditions
          if typeof options.should_exist is 'undefined'
            options.should_exist = options.source
          conditions.all options, next, extract
        .on 'both', (err) ->
          callback err, extracted

## Dependencies

    fs = require 'ssh2-fs'
    path = require 'path'
    each = require 'each'
    execute = require './execute'
    misc = require './misc'
    conditions = require './misc/conditions'
    child = require './misc/child'








