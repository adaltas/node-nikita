
# `mkdir([goptions], options, callback)`

Recursively create a directory. The behavior is similar to the Unix command
`mkdir -p`. It supports an alternative syntax where options is simply the path
of the directory to create.

## Options

*   `cwd`   
    Current working directory for relative paths.   
*   `uid`   
    Unix user id.   
*   `gid`   
    Unix group id.   
*   `mode`   
    Default to "0755".   
*   `directory`   
    Path or array of paths.   
*   `destination`   
    Alias for `directory`.   
*   `exclude`   
    Regular expression.   
*   `source`   
    Alias for `directory`.   
*   `ssh` (object|ssh2)   
    Run the action on a remote server using SSH, an ssh2 instance or an
    configuration object used to initialize the SSH connection.   

## Callback parameters

*   `err`   
    Error object if any.   
*   `created`   
    Number of created directories.   

## Simple usage

```js
require('mecano').mkdir('./some/dir', function(err, created){
  console.log(err ? err.message : "Directory created: " + !!created);
});
```

## Advance usage

```js
require('mecano').mkdir({
  ssh: ssh,
  destination: './some/dir',
  uid: 'a_user',
  gid: 'a_group'
  mode: 0o0777 // or '777'
}, function(err, created){
  console.log(err ? err.message : "Directory created: " + !!created);
});
```

    module.exports = (goptions, options, callback) ->
      wrap arguments, (options, next) ->
        modified = false
        # Validate parameters
        options = { directory: options } if typeof options is 'string'
        options.directory ?= options.source
        options.directory ?= options.destination
        return next new Error 'Missing directory option' unless options.directory?
        cwd = options.cwd ? process.cwd()
        options.directory = [options.directory] unless Array.isArray options.directory
        options.log? "Make directory #{options.directory}"
        each(options.directory)
        .on 'item', (directory, next) ->
          # first, we need to find which directory need to be created
          do_stats = ->
            end = false
            dirs = []
            directory = path.resolve cwd, directory # path.resolve also normalize
            # Create directory and its parent directories
            directories = directory.split('/')
            directories.shift() # first element is empty with absolute path
            directories = for i in [0...directories.length]
              '/' + directories.slice(0, directories.length - i).join '/'
            each(directories)
            .on 'item', (directory, i, next) ->
              return next() if end
              options.log? "Stat directory #{directory}"
              fs.stat options.ssh, directory, (err, stat) ->
                if err?.code is 'ENOENT' # if the directory is not yet created
                  directory.stat = stat
                  dirs.push directory
                  if i is directories.length - 1
                  then return do_create(dirs)
                  else return next()
                if stat?.isDirectory()
                  end = true
                  return  if i is 0 then do_update(stat) else do_create(dirs)
                if err
                  return next err
                else # a file or symlink exists at this location
                  return next new Error 'Not a directory: #{JSON.encode(directory)}'
            .on 'both', (err) ->
              return next err if err
          do_create = (directories) ->
            each(directories.reverse())
            .on 'item', (directory, next) ->
              # Directory name contains variables
              # eg /\${/ on './var/cache/${user}' creates './var/cache/'
              if options.exclude? and options.exclude instanceof RegExp
                return next() if options.exclude.test path.basename directory
              options.log? "Create directory #{directory}" unless directory is options.directory
              fs.mkdir options.ssh, directory, options, (err) ->
                return next err if err
                modified = true
                next()
            .on 'both', (err) ->
              return next err if err
              next()
          do_update = (stat) ->
            do_chown = ->
              chown
                ssh: options.ssh
                destination: directory
                uid: options.uid
                gid: options.gid
              , (err, owned) ->
                modified = true if owned
                do_chmod()
            do_chmod = ->
              return next() unless options.mode
              return next() if misc.mode.compare stat.mode, options.mode
              fs.chmod options.ssh, directory, options.mode, (err) ->
                modified = true
                next()
            do_chown()
          do_stats()
        .on 'both', (err) ->
          next err, modified

## Dependencies

    fs = require 'ssh2-fs'
    path = require 'path'
    each = require 'each'
    chown = require './chown'
    misc = require './misc'
    wrap = require './misc/wrap'





