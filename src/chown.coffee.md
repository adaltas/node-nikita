
`chmod([goptions], options, callback)`
--------------------------------------

Change the ownership of a file or a directory.

    fs = require 'ssh2-fs'
    each = require 'each'
    misc = require './misc'
    conditions = require './misc/conditions'
    child = require './misc/child'

`options`           Command options include:
*   `destination`   Where the file or directory is copied.
*   `mode`          Permissions of the file or the parent directory
*   `ssh`           Run the action on a remote server using SSH, an ssh2 instance or an configuration object used to initialize the SSH connection.
*   `log`           Function called with a log related messages.

`callback`          Received parameters are:
*   `err`           Error object if any.
*   `modified`      Number of files with modified permissions.

    module.exports = (goptions, options, callback) ->
      [goptions, options, callback] = misc.args arguments
      result = child()
      finish = (err, modified) ->
        callback err, modified if callback
        result.end err, modified
      misc.options options, (err, options) ->
        return finish err if err
        modified = 0
        each( options )
        .parallel(goptions.parallel)
        .on 'item', (options, next) ->
          # Validate parameters
          {ssh, uid, gid} = options
          return next new Error "Missing destination: #{options.destination}" unless options.destination
          return next() unless uid? and gid?
          options.log? "Stat #{options.destination}"
          fs.stat ssh, options.destination, (err, stat) ->
            return next err if err
            return next() if stat.uid is uid and stat.gid is gid
            options.log? "Change uid from #{stat.uid} to #{uid}" if stat.uid isnt uid
            options.log? "Change gid from #{stat.gid} to #{gid}" if stat.gid isnt gid
            fs.chown ssh, options.destination, uid, gid, (err) ->
              return next() err if err
              modified++
              next()
        .on 'both', (err) ->
          finish err, modified