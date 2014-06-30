
`upload([goptions], options, callback)`
---------------------------------------

Upload a file to a remote location. Options are
identical to the "write" function with the addition of
the "binary" option.

    fs = require 'ssh2-fs'
    path = require 'path'
    each = require 'each'
    misc = require './misc'
    conditions = require './misc/conditions'
    child = require './misc/child'
    execute = require './execute'
    write = require './write'

`options`           Command options include:
*   `binary`        Fast upload implementation, discard all the other option and use its own stream based implementation.
*   `from`          Replace from after this marker, a string or a regular expression.
*   `to`            Replace to before this marker, a string or a regular expression.
*   `match`         Replace this marker, a string or a regular expression.
*   `replace`       The content to be inserted, used conjointly with the from, to or match options.
*   `content`       Text to be written.
*   `source`        File path from where to extract the content, do not use conjointly with content.
*   `destination`   File path where to write content to.
*   `backup`        Create a backup, append a provided string to the filename extension or a timestamp if value is not a string.
*   `md5`           Validate uploaded file with md5 checksum (only for binary upload for now).
*   `sha1`          Validate uploaded file with sha1 checksum (only for binary upload for now).

`callback`          Received parameters are:
*   `err`           Error object if any.
*   `rendered`      Number of rendered files.

    module.exports = (goptions, options, callback) ->
      [goptions, options, callback] = misc.args arguments, parallel: 1
      result = child()
      finish = (err, uploaded) ->
        callback err, uploaded if callback
        result.end err, uploaded
      misc.options options, (err, options) ->
        return finish err if err
        uploaded = 0
        each( options )
        .parallel(goptions.parallel)
        .on 'item', (options, next) ->
          options.log? "Mecano `upload`"
          conditions.all options, next, ->
            # Start real work
            if options.binary
              get_checksum = (path, digest, callback) ->
                execute
                  ssh: options.ssh
                  cmd: "openssl #{digest} #{path}"
                  log: options.log
                  stdout: options.stdout
                  stderr: options.stderr
                , (err, executed, stdout, stderr) ->
                  return callback err if err
                  callback null, /[ ](.*)$/.exec(stdout.trim())[1]
              do_stat = ->
                options.log? "Check if #{options.destination} exists remotely"
                fs.stat options.ssh, options.destination, (err, stat) ->
                  return do_upload() if err?.code is 'ENOENT'
                  return next err if err
                  # return do_upload() unless exists
                  options.destination = "#{options.destination}/#{path.basename options.source}" if stat.isDirectory()
                  do_checksum()
              do_checksum = ->
                  return do_upload() unless options.md5 or options.sha1
                  options.log? "Make sure destination checksum is valid"
                  switch
                    when options.md5? then get_checksum options.destination, 'md5', (err, md5) ->
                      return next err if err
                      if md5 is options.md5
                      then next()
                      else do_upload()
                    when options.sha1? then get_checksum options.destination, 'sha1', (err, sha1) ->
                      return next err if err
                      if sha1 is options.sha1
                      then next()
                      else do_upload()
              do_upload = ->
                options.log? "Upload #{options.source}"
                fs.createWriteStream options.ssh, options.destination, (err, ws) ->
                  return next err if err
                  fs.createReadStream null, options.source, (err, rs) ->
                    return next err if err
                    rs.pipe(ws)
                    .on 'close', ->
                      uploaded++
                      do_md5()
                    .on 'error', next
                # options.ssh.sftp (err, sftp) ->
                #   from = fs.createReadStream options.source#, encoding: 'binary'
                #   to = sftp.createWriteStream options.destination#, encoding: 'binary'
                #   l = 0
                #   from.pipe to
                #   from.on 'error', next
                #   to.on 'error', next
                #   to.on 'close', ->
                #     uploaded++
                #     do_md5()
              do_md5 = ->
                return do_sha1() unless options.md5
                options.log? "Check md5 for '#{options.destination}'"
                get_checksum options.destination, 'md5', (err, md5) ->
                  return next new Error "Invalid md5 checksum" if md5 isnt options.md5
                  do_sha1()
              do_sha1 = ->
                return do_end() unless options.sha1
                options.log? "Check sha1 for '#{options.destination}'"
                get_checksum options.destination, 'sha1', (err, sha1) ->
                  return next new Error "Invalid sha1 checksum" if sha1 isnt options.sha1
                  do_end()
              do_end = ->
                options.log? "Upload succeed in #{options.destination}"
                next()
              return do_stat()
            options = misc.merge options, local_source: true
            write options, (err, written) ->
              uploaded++ if written is 1
              next err
        .on 'both', (err) ->
          finish err, uploaded
      result