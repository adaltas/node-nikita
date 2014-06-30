
`mkdir([goptions], options, callback)`
--------------------------------------

Recursively create a directory. The behavior is similar to the Unix command `mkdir -p`.
It supports an alternative syntax where options is simply the path of the directory
to create.

    fs = require 'ssh2-fs'
    path = require 'path'
    each = require 'each'
    misc = require './misc'
    conditions = require './misc/conditions'
    child = require './misc/child'
    chown = require './chown'

`options`           Command options include:
*   `cwd`           Current working directory for relative paths.
*   `uid`           Unix user id.
*   `gid`           Unix group id.
*   `mode`          Default to 0755.
*   `directory`     Path or array of paths.
*   `destination`   Alias for `directory`.
*   `exclude`       Regular expression.
*   `source`        Alias for `directory`.

`callback`          Received parameters are:
*   `err`           Error object if any.
*   `created`       Number of created directories

Simple usage:
```coffee
mecano.mkdir './some/dir', (err, created) ->
  console.info err?.message ? created
```

Advance usage:
```coffee
mecano.mkdir
  ssh: options.ssh
  destination: './some/dir'
  uid: 'me'
  gid: 'my_group'
  mode: 0o0777 or '777'
```

    module.exports = (goptions, options, callback) ->
      [goptions, options, callback] = misc.args arguments
      result = child()
      finish = (err, created) ->
        callback err, created if callback
        result.end err, created
      misc.options options, (err, options) ->
        return finish err if err
        created = 0
        each( options )
        .parallel(goptions.parallel)
        .on 'item', (options, next) ->
          # Validate parameters
          options = { directory: options } if typeof options is 'string'
          options.directory ?= options.source
          options.directory ?= options.destination
          return next new Error 'Missing directory option' unless options.directory?
          cwd = options.cwd ? process.cwd()
          options.directory = [options.directory] unless Array.isArray options.directory
          conditions.all options, next, ->
            mode = options.mode or 0o0755
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
                  created++
                  next err
              do_update = (stat) ->
                modified = false
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
                  return do_end() unless mode
                  # todo: fix this one
                  return do_end() if misc.mode.compare stat.mode, mode
                  fs.chmod options.ssh, directory, mode, (err) ->
                    modified = true
                    do_end()
                do_end = ->
                  created++ if modified
                  next()
                do_chown()
              do_stats()
            .on 'both', (err) ->
              next err
        .on 'both', (err) ->
          finish err, created
      result