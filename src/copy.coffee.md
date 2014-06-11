
`cp` `copy([goptions], options, callback)`
------------------------------------------

Copy a file. The behavior is similar to the one of the `cp`
Unix utility. Copying a file over an existing file will
overwrite it.

    fs = require 'ssh2-fs'
    path = require 'path'
    each = require 'each'
    misc = require './misc'
    conditions = require './misc/conditions'
    child = require './misc/child'
    chmod = require './chmod'
    chown = require './chown'

`options`           Command options include:
*   `source`        The file or directory to copy.
*   `destination`   Where the file or directory is copied.
*   `not_if_exists` Equals destination if true.
*   `mode`          Permissions of the file or the parent directory
*   `ssh`           Run the action on a remote server using SSH, an ssh2 instance or an configuration object used to initialize the SSH connection.

`callback`          Received parameters are:
*   `err`           Error object if any.
*   `copied`        Number of files or parent directories copied.

Todo:
*   preserve permissions if `mode` is `true`

    module.exports = (goptions, options, callback) ->
      [goptions, options, callback] = misc.args arguments
      misc.options options, (err, options) ->
        return callback err if err
        copied = 0
        each( options )
        .parallel(goptions.parallel)
        .on 'item', (options, next) ->
          # Validate parameters
          return next new Error 'Missing source' unless options.source
          return next new Error 'Missing destination' unless options.destination
          # return next new Error 'SSH not yet supported' if options.ssh
          # Cancel action if destination exists ? really ? no md5 comparaison, strange
          options.not_if_exists = options.destination if options.not_if_exists is true
          # Start real work
          conditions.all options, next, ->
            modified = false
            srcStat = null
            dstStat = null
            options.log? "Stat source file"
            fs.stat options.ssh, options.source, (err, stat) ->
              # Source must exists
              return next err if err
              srcStat = stat
              options.log? "Stat destination file"
              fs.stat options.ssh, options.destination, (err, stat) ->
                return next err if err and err.code isnt 'ENOENT'
                dstStat = stat
                sourceEndWithSlash = options.source.lastIndexOf('/') is options.source.length - 1
                if srcStat.isDirectory() and dstStat and not sourceEndWithSlash
                  options.destination = path.resolve options.destination, path.basename options.source
                if srcStat.isDirectory() then do_directory(options.source, next) else do_copy(options.source, next)
            # Copy a directory
            do_directory = (dir, callback) ->
              options.log? "Source is a directory"
              each()
              .files("#{dir}/**")
              .on 'item', (file, next) ->
                do_copy file, next
              .on 'both', callback
            do_copy = (source, callback) ->
              if srcStat.isDirectory()
                destination = path.resolve options.destination, path.relative options.source, source
              else if not srcStat.isDirectory() and dstStat?.isDirectory()
                destination = path.resolve options.destination, path.basename source
              else
                destination = options.destination
              fs.stat options.ssh, source, (err, stat) ->
                return callback err if err
                if stat.isDirectory()
                then do_copy_dir source, destination
                else do_copy_file source, destination
              do_copy_dir = (source, destination) ->
                return callback() if source is options.source
                options.log? "Create directory #{destination}"
                # todo, add permission
                fs.mkdir options.ssh, destination, (err) ->
                  return callback() if err?.code is 'EEXIST'
                  return callback err if err
                  modified = true
                  do_end()
              # Copy a file
              do_copy_file = (source, destination) ->
                misc.file.compare options.ssh, [source, destination], (err, md5) ->
                  # Destination may not exists
                  return callback err if err and err.message.indexOf('Does not exist') isnt 0
                  # File are the same, we can skip copying
                  return do_chown destination if md5
                  options.log? "Copy file from #{source} into #{destination}"
                  misc.file.copyFile options.ssh, source, destination, (err) ->
                    return callback err if err
                    modified = true
                    do_chown destination
                  # fs.createReadStream options.ssh, source, (err, rs) ->
                  #   return next err if err
                  #   fs.createWriteStream options.ssh, destination, (err, ws) ->
                  #     return next err if err
                  #     rs.pipe(ws)
                  #     .on 'close', ->
                  #       modified = true
                  #       do_chown destination
                  #     .on 'error', callback
              do_chown = (destination) ->
                return do_chmod() if not options.uid and not options.gid
                chown
                  ssh: options.ssh
                  log: options.log
                  destination: destination
                  uid: options.uid
                  gid: options.gid
                , (err, chowned) ->
                  return callback err if err
                  modified = chowned if chowned
                  do_chmod()
              do_chmod = (destination) ->
                return do_end() if not options.mode
                chmod
                  ssh: options.ssh
                  log: options.log
                  destination: options.destination
                  mode: options.mode
                , (err, chmoded) ->
                  return callback err if err
                  modified = chmoded if chmoded
                  do_end()
              do_end = ->
                copied++ if modified
                callback()
        .on 'both', (err) ->
          callback err, copied