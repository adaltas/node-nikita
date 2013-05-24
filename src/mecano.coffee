
fs = require 'fs'
path = require 'path'
url = require 'url'
util = require 'util'
each = require 'each'
eco = require 'eco'
exec = require 'superexec'
request = require 'request'
Ftp = require 'jsftp'
{EventEmitter} = require 'events'

conditions = require './conditions'
misc = require './misc'
child = require './child'


###

Mecano gather a set of functions usually used during system deployment. All the functions share a 
common API with flexible options.

Functions include "copy", "download", "exec", "extract", "git", "link", "mkdir", "move", "remove", "render", "service", "write". They all share common usages and philosophies:   
*   Run actions both locally and remotely over SSH.   
*   Ability to see if an action had an effect through the second argument provided in the callback.   
*   Common API with options and callback arguments and calling the callback with an error and the number of affected actions.   
*   Run one or multiple actions depending on option argument being an object or an array of objects.   

###
mecano = module.exports = 
  ###

  `cp` `copy(options, callback)`
  ------------------------------

  Copy a file. The behavior is similar to the one of the `cp` 
  Unix utility. Copying a file over an existing file will 
  overwrite it.

  `options`             Command options include:   

  *   `source`          The file or directory to copy.
  *   `destination`     Where the file or directory is copied.
  *   `not_if_exists`   Equals destination if true.
  *   `chmod`           Permissions of the file or the parent directory
  *   `ssh`             Run the action on a remote server using SSH, an ssh2 instance or an configuration object used to initialize the SSH connection.   
 
  `callback`            Received parameters are:   

  *   `err`             Error object if any.   
  *   `copied`          Number of files or parent directories copied.

  todo:
  *   preserve permissions if `chmod` is `true`

  ###
  copy: (options, callback) ->
    misc.options options, (err, options) ->
      return callback err if err
      copied = 0
      each( options )
      .on 'item', (options, next) ->
        return next new Error 'Missing source' unless options.source
        return next new Error 'Missing destination' unless options.destination
        return next new Error 'SSH not yet supported' if options.ssh
        # Cancel action if destination exists ? really ? no md5 comparaison, strange
        options.not_if_exists = options.destination if options.not_if_exists is true
        search = ->
          srcStat = null
          dstStat = null
          fs.stat options.source, (err, stat) ->
            # Source must exists
            return next err if err
            srcStat = stat
            fs.stat options.destination, (err, stat) ->
              dstStat = stat
              sourceEndWithSlash = options.source.lastIndexOf('/') is options.source.length - 1
              if srcStat.isDirectory() and dstStat and not sourceEndWithSlash
                options.destination = path.resolve options.destination, path.basename options.source
              if srcStat.isDirectory() then directory options.source else copy options.source, next
          # Copy a directory
          directory = (dir) ->
            each()
            .files("#{dir}/**")
            .on 'item', (file, next) ->
              copy file, next
            .on 'both', next
          copy = (source, next) ->
            if srcStat.isDirectory()
              destination = path.resolve options.destination, path.relative options.source, source
            else if not srcStat.isDirectory() and dstStat?.isDirectory()
              destination = path.resolve options.destination, path.basename source
            else
              destination = options.destination
            fs.stat source, (err, stat) ->
              if stat.isDirectory()
              then copyDir source, destination, next
              else copyFile source, destination, next
          copyDir = (source, destination, next) ->
            return next() if source is options.source
            # todo, add permission
            misc.file.mkdir options.ssh, destination, (err) ->
              return next() if err?.code is 'EEXIST'
              return next err if err
              finish next
          # Copy a file
          copyFile = (source, destination, next) ->
            misc.file.compare [source, destination], (err, md5) ->
              return next err if err and err.message.indexOf('Does not exist') isnt 0
              # File are the same, we can skip copying
              return next() if md5
              # Copy
              input = fs.createReadStream source
              output = fs.createWriteStream destination
              input.pipe(output).on 'close', (err) ->
                return next err if err
                chmod source, next
          chmod = (file, next) ->
            return finish next if not options.chmod or options.chmod is dstStat.mode
            fs.chmod options.destination, options.chmod, (err) ->
              return next err if err
              finish next
          finish = (next) ->
            copied++
            next()
        conditions.all options, next, search
      .on 'both', (err) ->
        callback err, copied
  ###

  `download(options, callback)`
  -----------------------------

  Download files using various protocols.

  When executed locally: the `http` scheme is handled 
  with the "request" module; the `ftp` scheme is handled 
  with the "jsftp"; the `file` scheme is handle with the navite 
  `fs` module.

  `options`         Command options include:   

  *   `source`      File, HTTP URL, FTP, GIT repository. File is the default protocol if source is provided without a scheme.   
  *   `destination` Path where the file is downloaded.   
  *   `force`       Overwrite destination file if it exists.   

  `callback`        Received parameters are:   

  *   `err`         Error object if any.   
  *   `downloaded`  Number of downloaded files

  File example

      mecano.download
        source: 'file://path/to/something'
        destination: 'node-sigar.tgz'
      , (err, downloaded) -> ...

  HTTP example

      mecano.download
        source: 'https://github.com/wdavidw/node-sigar/tarball/v0.0.1'
        destination: 'node-sigar.tgz'
      , (err, downloaded) -> ...

  FTP example

      mecano.download
        source: 'ftp://myhost.com:3334/wdavidw/node-sigar/tarball/v0.0.1'
        destination: 'node-sigar.tgz'
        user: "johndoe",
        pass: "12345"
      , (err, downloaded) -> ...

  File example
  
  ###
  download: (options, callback) ->
    result = child mecano
    finish = (err, downloaded) ->
      callback err, downloaded if callback
      result.end err, downloaded
    misc.options options, (err, options) ->
      return finish err if err
      downloaded = 0
      each( options )
      .on 'item', (options, next) ->
        return next new Error "Missing source: #{options.source}" unless options.source
        return next new Error "Missing destination: #{options.destination}" unless options.destination
        options.force ?= false
        prepare = () ->
          misc.file.exists options.ssh, options.destination, (err, exists) ->
            # Use previous download
            if exists and not options.force
              next()
            # Remove previous dowload and download again
            else if exists
              mecano.remove
                ssh: options.ssh
                destination: options.destination
              , (err) ->
                return next err if err
                download()
            else download()
        download = () ->
          u = url.parse options.source
          scheme = 'file' # For now, we temporary disable ftp and others schemes
          if options.ssh
            mecano.execute
              ssh: options.ssh
              cmd: "curl #{options.source} -o #{options.destination}"
            , (err, executed) ->
              next err
          else
            destination = fs.createWriteStream(options.destination)
            if u.protocol is 'http:'
              options.url = options.source
              request(options).pipe(destination)
            else if u.protocol is 'ftp:'
              options.host ?= u.hostname
              options.port ?= u.port
              if u.auth
                {user, pass} = u.auth.split ':'
              options.user ?= user
              options.pass ?= pass
              ftp = new Ftp options
              ftp.getGetSocket u.pathname, (err, source) ->
                return next err if err
                source.pipe destination
                source.resume()
            else
              source = fs.createReadStream(u.pathname)
              source.pipe destination
            destination.on 'close', () ->
              downloaded++
              next()
            destination.on 'error', (err) ->
              # No test agains this but error in case 
              # of connection issue leave an empty file
              mecano.remove destination, (err) ->
                next err
        prepare()
      .on 'both', (err) ->
        finish err, downloaded
  ###

  `exec` `execute([goptions], options, callback)`
  -----------------------------------------------
  Run a command locally or with ssh if the `host` is provided. Global options is
  optional and is used in case where options is defined as an array of 
  multiple commands. Note, `opts` inherites all the properties of `goptions`.

  `goptions`        Global options includes:

  *   `parallel`    Wether the command are run in sequential, parallel 
  or limited concurrent mode. See the `node-each` documentation for more 
  details. Default to sequential (false).
        
  `options`           Include all conditions as well as:  

  *   `cmd`           String, Object or array; Command to execute.   
  *   `env`           Environment variables, default to `process.env`.   
  *   `cwd`           Current working directory.   
  *   `uid`           Unix user id.   
  *   `gid`           Unix group id.   
  *   `code`          Expected code(s) returned by the command, int or array of int, default to 0.  
  *   `code_skipped`  Expected code(s) returned by the command if it has no effect, executed will not be incremented, int or array of int.   
  *   `stdout`        Writable EventEmitter in which command output will be piped.   
  *   `stderr`        Writable EventEmitter in which command error will be piped.   
  *   `ssh`           Run the action on a remote server using SSH, an ssh2 instance or an configuration object used to initialize the SSH connection.   

  `callback`        Received parameters are:   

  *   `err`         Error if any.   
  *   `executed`    Number of executed commandes.   
  *   `stdout`      Stdout value(s) unless `stdout` option is provided.   
  *   `stderr`      Stderr value(s) unless `stderr` option is provided.   

  ###
  execute: (options, callback) ->
    result = child mecano
    finish = (err, created, stdout, stderr) ->
      callback err, created, stdout, stderr if callback
      result.end err, created
    isArray = Array.isArray options
    misc.options options, (err, options) ->
      return finish err if err
      executed = 0
      stdouts = []
      stderrs = []
      escape = (cmd) ->
        esccmd = ''
        for char in cmd
          if char is '$'
            esccmd += '\\'
          esccmd += char
        esccmd
      stds = if callback then callback.length > 2 else false
      each( options )
      .parallel( true )
      .on 'item', (options, i, next) ->
        options = { cmd: options } if typeof options is 'string'
        return next new Error "Missing cmd: #{options.cmd}" unless options.cmd?
        options.code ?= [0]
        options.code = [options.code] unless Array.isArray options.code
        options.code_skipped ?= []
        options.code_skipped = [options.code_skipped] unless Array.isArray options.code_skipped
        cmd = () ->
          run = exec options
          stdout = stderr = []
          if options.stdout
            run.stdout.pipe options.stdout
          if stds
            run.stdout.on 'data', (data) ->
              stdout.push data
          if options.stderr
            run.stderr.pipe options.stderr
          if stds
            run.stderr.on 'data', (data) ->
              stderr.push data
          run.on "exit", (code) ->
            # Givent some time because the "exit" event is sometimes
            # called before the "stdout" "data" event when runing
            # `make test`
            setTimeout ->
              stdouts.push if stds then stdout.join('') else undefined
              stderrs.push if stds then stderr.join('') else undefined
              if options.code.indexOf(code) is -1 and options.code_skipped.indexOf(code) is -1 
                err = new Error "Invalid exec code #{code}"
                err.code = code
                return next err
              executed++ if options.code_skipped.indexOf(code) is -1 
              next()
            , 1
        conditions.all options, next, cmd
      .on 'both', (err) ->
        stdouts = stdouts[0] unless isArray
        stderrs = stderrs[0] unless isArray
        finish err, executed, stdouts, stderrs
    result
  ###

  `extract(options, callback)` 
  ----------------------------

  Extract an archive. Multiple compression types are supported. Unless 
  specified as an option, format is derived from the source extension. At the 
  moment, supported extensions are '.tgz', '.tar.gz' and '.zip'.   

  `options`             Command options include:   

  *   `source`          Archive to decompress.   
  *   `destination`     Default to the source parent directory.   
  *   `format`          One of 'tgz' or 'zip'.   
  *   `creates`         Ensure the given file is created or an error is send in the callback.   
  *   `not_if_exists`   Cancel extraction if file exists.   
  *   `ssh`             Run the action on a remote server using SSH, an ssh2 instance or an configuration object used to initialize the SSH connection.   

  `callback`            Received parameters are:   

  *   `err`             Error object if any.   
  *   `extracted`       Number of extracted archives.   

  ###
  extract: (options, callback) ->
    misc.options options, (err, options) ->
      return callback err if err
      extracted = 0
      each( options )
      .on 'item', (options, next) ->
        return next new Error "Missing source: #{options.source}" unless options.source
        destination = options.destination ? path.dirname options.source
        # Deal with format option
        if options.format?
          format = options.format
        else
          if /\.(tar\.gz|tgz)$/.test options.source
            format = 'tgz'
          else if /\.zip$/.test options.source
            format = 'zip'
          else
            ext = path.extname options.source
            return next new Error "Unsupported extension, got #{JSON.stringify(ext)}"
        # Working step
        extract = () ->
          cmd = null
          switch format
            when 'tgz' then cmd = "tar xzf #{options.source} -C #{destination}"
            when 'zip' then cmd = "unzip -u #{options.source} -d #{destination}"
          # exec cmd, (err, stdout, stderr) ->
          options.cmd = cmd
          exec options, (err, stdout, stderr) ->
            return next err if err
            creates()
        # Step for `creates`
        creates = () ->
          return success() unless options.creates?
          misc.file.exists options.ssh, options.creates, (err, exists) ->
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
  ###
  
  `git`
  -----

  `options`             Command options include:   

  *   `source`          Git source repository address.   
  *   `destination`     Directory where to clone the repository.   
  *   `revision`        Git revision, branch or tag.   
  *   `ssh`             Run the action on a remote server using SSH, an ssh2 instance or an configuration object used to initialize the SSH connection.   
  *   `stdout`          Writable EventEmitter in which command output will be piped.   
  *   `stderr`          Writable EventEmitter in which command error will be piped.   
  
  ###
  git: (options, callback) ->
    misc.options options, (err, options) ->
      return callback err if err
      updated = 0
      each( options )
      .on 'item', (options, next) ->
        options.revision ?= 'HEAD'
        rev = null
        prepare = ->
          misc.file.exists options.ssh, options.destination, (err, exists) ->
            return clone() unless exists
            # return next new Error "Destination not a directory, got #{options.destination}" unless stat.isDirectory()
            gitDir = "#{options.destination}/.git"
            misc.file.exists options.ssh, gitDir, (err, exists) ->
              return next "Not a git repository" unless exists
              log()
        clone = ->
          mecano.exec
            ssh: options.ssh
            cmd: "git clone #{options.source} #{options.destination}"
            cwd: path.dirname options.destination
            stdout: options.stdout
            stderr: options.stderr
          , (err, executed, stdout, stderr) ->
            return next err if err
            checkout()
        log = ->
          mecano.exec
            ssh: options.ssh
            cmd: "git log --pretty=format:'%H' -n 1"
            cwd: options.destination
            stdout: options.stdout
            stderr: options.stderr
          , (err, executed, stdout, stderr) ->
            return next err if err
            current = stdout.trim()
            mecano.exec
              ssh: options.ssh
              cmd: "git rev-list --max-count=1 #{options.revision}"
              cwd: options.destination
            , (err, executed, stdout, stderr) ->
              return next err if err
              if stdout.trim() isnt current
              then checkout()
              else next()
        checkout = ->
          mecano.exec
            ssh: options.ssh
            cmd: "git checkout #{options.revision}"
            cwd: options.destination
            stdout: options.stdout
            stderr: options.stderr
          , (err) ->
            return next err if err
            updated++
            next()
        conditions.all options, next, prepare
      .on 'both', (err) ->
        callback err, updated

  ###

  `ln` `link(options, callback)`
  ------------------------------
  Create a symbolic link and it's parent directories if they don't yet
  exist.

  `options`             Command options include:   

  *   `source`          Referenced file to be linked.   
  *   `destination`     Symbolic link to be created.   
  *   `exec`            Create an executable file with an `exec` command.   
  *   `chmod`           Default to 0755.   

  `callback`            Received parameters are:   

  *   `err`             Error object if any.   
  *   `linked`          Number of created links.   

  ###
  link: (options, callback) ->
    misc.options options, (err, options) ->
      return callback err if err
      return next new Error 'SSH not yet supported' if options.ssh
      linked = 0
      sym_exists = (options, callback) ->
        misc.file.exists options.ssh, options.destination, (err, exists) ->
          return callback null, false unless exists
          fs.readlink options.destination, (err, resolvedPath) ->
            return callback err if err
            return callback null, true if resolvedPath is options.source
            fs.unlink options.destination, (err) ->
              return callback err if err
              callback null, false
      sym_create = (options, callback) ->
        fs.symlink options.source, options.destination, (err) ->
          return callback err if err
          linked++
          callback()
      exec_exists = (options, callback) ->
        misc.file.exists options.ssh, options.destination, (err, exists) ->
          return callback null, false unless exists
          misc.file.readFile options.ssh, options.destination, (err, content) ->
            return callback err if err
            exec_cmd = /exec (.*) \$@/.exec(content)[1]
            callback null, exec_cmd and exec_cmd is options.source
      exec_create = (options, callback) ->
        content = """
        #!/bin/bash
        exec #{options.source} $@
        """
        misc.file.writeFile options.ssh, options.destination, content, (err) ->
          return callback err if err
          fs.chmod options.destination, options.chmod, (err) ->
            return callback err if err
            linked++
            callback()
      parents = for option in options then path.normalize path.dirname option.destination
      mecano.mkdir parents, (err, created) ->
        return callback err if err
        each( options )
        .parallel( true )
        .on 'item', (options, next) ->
          return next new Error "Missing source, got #{JSON.stringify(options.source)}" unless options.source
          return next new Error "Missing destination, got #{JSON.stringify(options.destination)}" unless options.destination
          options.chmod ?= 0o0755
          dispatch = ->
            if options.exec
              exec_exists options, (err, exists) ->
                return next() if exists
                exec_create options, next
            else
              sym_exists options, (err, exists) ->
                return next() if exists
                sym_create options, next
          dispatch()
        .on 'both', (err) ->
          callback err, linked
  ###

  `mkdir(options, callback)`
  --------------------------

  Recursively create a directory. The behavior is similar to the Unix command `mkdir -p`. 
  It supports an alternative syntax where options is simply the path of the directory
  to create.

  `options`           Command options include:   

  *   `source`        Path or array of paths.   
  *   `directory`     Alias for `source`
  *   `destination`   Alias for `source`
  *   `exclude`       Regular expression.   
  *   `chmod`         Default to 0755.  
  *   `cwd`           Current working directory for relative paths.   

  `callback`          Received parameters are:   

  *   `err`           Error object if any.   
  *   `created`       Number of created directories

  Simple usage:

      mecano.mkdir './some/dir', (err, created) ->
        console.log err?.message ? created

  ###
  mkdir: (options, callback) ->
    result = child mecano
    finish = (err, created) ->
      callback err, created if callback
      result.end err, created
    misc.options options, (err, options) ->
      return finish err if err
      created = 0
      each( options )
      .on 'item', (options, next) ->
        options = { source: options } if typeof options is 'string'
        options.source ?= options.directory
        options.source ?= options.destination
        return next new Error 'Missing source option' unless options.source?
        cwd = options.cwd ? process.cwd()
        options.source = path.resolve cwd, options.source
        check = () ->
          misc.file.stat options.ssh, options.source, (err, stat) ->
            return create() if err and err.code is 'ENOENT'
            return next err if err
            # nothing to do if exist and is a dir
            return next() if stat.isDirectory()
            # error if exists and isn't a dir
            next err 'Invalid source, got #{JSON.encode(options.source)}'
        create = () ->
          options.chmod ?= 0o0755
          current = ''
          dirCreated = false
          dirs = options.source.split '/'

          each( dirs )
          .on 'item', (dir, next) ->
            # Directory name contains variables
            # eg /\${/ on './var/cache/${user}' creates './var/cache/'
            if options.exclude? and options.exclude instanceof RegExp
              return next() if options.exclude.test dir
            # Empty Dir caused by split
            # ..commented because `resolve` should clean the path
            # return next() if dir is ''
            current += "/#{dir}"
            misc.file.exists options.ssh, current, (err, exists) ->
              return next() if exists
              misc.file.mkdir options.ssh, current, options, (err) ->
                return next err if err
                dirCreated = true
                next()
          .on 'both', (err) ->
            created++ if dirCreated
            next err
        conditions.all options, next, check
      .on 'both', (err) ->
        finish err, created
    result
  ###

  `mv` `move(options, callback)`
  --------------------------------

  More files and directories.

  `options`         Command options include:   

  *   `source`      File or directory to move.  
  *   `destination` Final name of the moved resource.    

  `callback`        Received parameters are:   

  *   `err`         Error object if any.   
  *   `moved`        Number of moved resources.

  Example

    mecano.mv
      source: __dirname
      desination: '/temp/my_dir'
    , (err, moved) ->
      console.log "#{moved} dir moved"

  ###
  move: (options, callback) ->
    misc.options options, (err, options) ->
      return callback err if err
      moved = 0
      each( options )
      .on 'item', (options, next) ->
        return next new Error 'SSH not yet supported' if options.ssh
        move = ->
          fs.rename options.source, options.destination, (err) ->
            return next err if err
            moved++
            next()
        conditions.all options, next, move
      .on 'both', (err) ->
        callback err, moved
  ###

  `rm` `remove(options, callback)`
  --------------------------------

  Recursively remove files, directories and links. Internally, the function 
  use the [rimraf](https://github.com/isaacs/rimraf) library.

  `options`         Command options include:   

  *   `source`      File, directory or pattern.  
  *   `destination` Alias for "source". 

  `callback`        Received parameters are:   

  *   `err`         Error object if any.   
  *   `removed`     Number of removed sources.   

  Example

      mecano.rm './some/dir', (err, removed) ->
        console.log "#{removed} dir removed"
  
  Removing a directory unless a given file exists

      mecano.rm
        source: './some/dir'
        not_if_exists: './some/file'
      , (err, removed) ->
        console.log "#{removed} dir removed"
  
  Removing multiple files and directories

      mecano.rm [
        { source: './some/dir', not_if_exists: './some/file' }
        './some/file'
      ], (err, removed) ->
        console.log "#{removed} dirs removed"

  ###
  remove: (options, callback) ->
    result = child mecano
    finish = (err, removed) ->
      callback err, removed if callback
      result.end err, removed
    misc.options options, (err, options) ->
      return finish err if err
      removed = 0
      each( options )
      .on 'item', (options, next) ->
        options = source: options if typeof options is 'string'
        options.source ?= options.destination
        return next new Error "Missing source" unless options.source?
        remove = ->
          if options.ssh
            misc.file.exists options.ssh, options.source, (err, exists) ->
              return next err if err
              removed++ if exists
              misc.file.remove options.ssh, options.source, next
          else
            each()
            .files(options.source)
            .on 'item', (file, next) ->
              removed++
              misc.file.remove options.ssh, file, next
            .on 'error', (err) ->
              next err
            .on 'end', ->
              next()
        conditions.all options, next, remove
      .on 'both', (err) ->
        finish err, removed
    result
  ###

  `render(options, callback)`
  ---------------------------
  
  Render a template file At the moment, only the 
  [ECO](http://github.com/sstephenson/eco) templating engine is integrated.   
  
  `options`           Command options include:   
  
  *   `engine`        Template engine to use, default to "eco"   
  *   `content`       Templated content, bypassed if source is provided.   
  *   `source`        File path where to extract content from.   
  *   `destination`   File path where to write content to or a callback.   
  *   `context`       Map of key values to inject into the template.   
  *   `local_source`  Treat the source as local instead of remote, only apply with "ssh" option.   

  `callback`          Received parameters are:   
  
  *   `err`           Error object if any.   
  *   `rendered`      Number of rendered files.   

  If destination is a callback, it will be called multiple times with the   
  generated content as its first argument.
  
  ###
  render: (options, callback) ->
    misc.options options, (err, options) ->
      return callback err if err
      rendered = 0
      each( options )
      .on 'item', (options, next) ->
        return next new Error 'Missing source or content' unless options.source or options.content
        return next new Error 'Missing destination' unless options.destination
        readSource = ->
          return writeContent() unless options.source
          ssh = if options.local_source then null else options.ssh
          misc.file.exists ssh, options.source, (err, exists) ->
            return next new Error "Invalid source, got #{JSON.stringify(options.source)}" unless exists
            misc.file.readFile ssh, options.source, (err, content) ->
              return next err if err
              options.content = content
              writeContent()
        writeContent = ->
          options.source = null
          mecano.write options, (err, written) ->
            return next err if err
            rendered++ if written
            next()
        conditions.all options, next, readSource
      .on 'both', (err) ->
        callback err, rendered
  ###
  `service(options, callback)`
  ----------------------------

  Install a service. For now, only yum over SSH.
  
  `options`             Command options include:   

  *    name             Package name.
  *    startup          Run service daemon on startup.
  *    yum_name         Name used by the yum utility, default to "name".
  *    chk_name         Name used by the chkconfig utility, default to "srv_name" and "name".
  *    srv_name         Name used by the service utility, default to "name".
  *    start            Ensure the service is started, a boolean.
  *    stop             Ensure the service is stopped, a boolean.
  
  `callback`            Received parameters are:   
  
  *   `err`             Error object if any.   
  *   `modified`        Number of action taken (installed, updated, started or stoped). 

  ###
  service: (options, callback) ->
    misc.options options, (err, options) ->
      return callback err if err
      serviced = 0
      each( options )
      .on 'item', (options, next) ->
        return next new Error 'Missing service name' unless options.name
        return next new Error 'Restricted to Yum over SSH' unless options.ssh
        return next new Error 'Invalid configuration, start conflict with stop' if options.start? and options.start is options.stop
        pkgname = options.yum_name or options.name
        chkname = options.chk_name or options.srv_name or options.name
        srvname = options.srv_name or options.name
        if options.startup? and typeof options.startup isnt 'string'
            options.startup = if options.startup then '2345' else ''
        modified = false
        stderr = new EventEmitter()
        stderr.writable = true
        stderr.write = (data) ->
          # if /Existing lock/.test data.toString()
          # quit current process, thow an exception
        installed = ->
          mecano.execute
            ssh: options.ssh
            cmd: "yum list installed | grep ^#{pkgname}\\\\."
            code_skipped: 1
            # stdout: stdout
            stderr: stderr
          , (err, installed) ->
            return next err if err
            if installed then updates() else install()
        updates = ->
          mecano.execute
            ssh: options.ssh
            cmd: "yum list updates | grep ^#{pkgname}\\\\."
            code_skipped: 1
          , (err, outdated) ->
            return next err if err
            if outdated then install() else startuped()
        install = ->
          mecano.execute
            ssh: options.ssh
            cmd: "yum install -y #{pkgname}"
            code_skipped: 1
          , (err, succeed) ->
            return next err if err
            return next new Error "No package #{pkgname} available." unless succeed
            modified = true if installed
            startuped()
        startuped = ->
          return started() unless options.startup?
          mecano.execute
            ssh: options.ssh
            cmd: "chkconfig --list #{chkname}"
            code_skipped: 1
          , (err, registered, stdout, stderr) ->
            return next err if err
            # Invalid service name return code is 0 and message in stderr start by error
            return next new Error "Invalid chkconfig name #{chkname}" if /^error/.test stderr
            current_startup = ''
            if registered
              for c in stdout.split(' ').pop().trim().split '\t'
                [level, status] = c.split ':'
                current_startup += level if status is 'on'
            return started() if options.startup is current_startup
            modified = true
            if options.startup
            then startup_add()
            else startup_del()
        startup_add = ->
          startup_on = startup_off = ''
          for i in [0...6]
            if options.startup.indexOf(i) isnt -1
            then startup_on += i
            else startup_off += i
          cmd = "chkconfig --add #{chkname};"
          cmd += "chkconfig --level #{startup_on} #{chkname} on;" if startup_on
          cmd += "chkconfig --level #{startup_off} #{chkname} off;" if startup_off
          mecano.execute
            ssh: options.ssh
            cmd: cmd
          , (err, stream) ->
            return next err if err
            started()
        startup_del = ->
          mecano.execute
            ssh: options.ssh
            cmd: "chkconfig --del #{chkname}"
          , (err, stream) ->
            return next err if err
            started()
        started = ->
          return finish() unless options.action
          mecano.execute
            ssh: options.ssh
            cmd: "service #{srvname} status"
            code_skipped: 3
          , (err, started) ->
            return next err if err
            if started
              return action() unless options.action is 'start'
            else
              return action() unless options.action is 'stop'
            finish() 
            # action = if options.start? then 'start' else 'stop'
            # if not started and action is start then start 'start'
            # if started and action isnt start then start 'stop'
            # else finish()
        action = ->
          mecano.execute
            ssh: options.ssh
            cmd: "service #{srvname} #{options.action}"
          , (err, executed) ->
            return next err if err
            finish()
        finish = ->
          serviced++ if modified
          next()
        conditions.all options, next, installed
      .on 'both', (err) ->
        callback err, serviced
  ###

  `upload(options, callback)`
  ---------------------------
  
  Upload a file to a remote location. Options are 
  identical to the "write" function with the addition of 
  the "binary" option.
  
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

  `callback`          Received parameters are:   
  
  *   `err`           Error object if any.   
  *   `rendered`      Number of rendered files. 

  ###
  upload: (options, callback) ->
    misc.options options, (err, options) ->
      return callback err if err
      uploaded = 0
      each( options )
      .on 'item', (options, next) ->
        if options.binary
          return options.ssh.sftp (err, sftp) ->
            from = fs.createReadStream options.source
            to = sftp.createWriteStream options.destination
            from.pipe to
            from.on 'error', (err) ->
              next err
            from.on 'end', ->
              uploaded++
              next()
        options = misc.merge options, local_source: true
        mecano.write options, (err, written) ->
          uploaded++ if written is 1
          next err
      .on 'both', (err) ->
        callback err, uploaded
  ###

  `write(options, callback)`
  --------------------------

  Write a file or a portion of an existing file.
  
  `options`            Command options include:   
  
  *   `from`           Replace from after this marker, a string or a regular expression.   
  *   `to`             Replace to before this marker, a string or a regular expression.   
  *   `match`          Replace this marker, a string or a regular expression.   
  *   `replace`        The content to be inserted, used conjointly with the from, to or match options.   
  *   `content`        Text to be written, an alternative to source which reference a file.   
  *   `source`         File path from where to extract the content, do not use conjointly with content.   
  *   `destination`    File path where to write content to.   
  *   `backup`         Create a backup, append a provided string to the filename extension or a timestamp if value is not a string.   
  *   `append`         Append the content to the destination file. If destination does not exist, the file will be created. When used with the `match` and `replace` options, it will append the `replace` value at the end of the file if no match if found and if the value is a string.   
  *   `ssh`            Run the action on a remote server using SSH, an ssh2 instance or an configuration object used to initialize the SSH connection.   
  
  `callback`           Received parameters are:   
  
  *   `err`            Error object if any.   
  *   `rendered`       Number of rendered files.   
  
  Example replacing part of a file using from and to markers

      mecano.write
        content: 'here we are\n# from\nlets try to replace that one\n# to\nyou coquin'
        from: '# from\n'
        to: '# to'
        replace: 'my friend\n'
        destination: "#{scratch}/a_file"
      , (err, written) ->
        # here we are\n# from\nmy friend\n# to\nyou coquin
  
  Example replacing part of a file using a regular expression

      mecano.write
        content: 'here we are\nlets try to replace that one\nyou coquin'
        match: /(.*try) (.*)/
        replace: ['my friend, $1']
        destination: "#{scratch}/a_file"
      , (err, written) ->
        # here we are\nmy friend, lets try\nyou coquin

  Example replacing with the global and multiple lines options

      mecano.write
        content: '#A config file\n#property=30\nproperty=10\n#End of Config'
        match: /^property=.*$/mg
        replace: 'property=50'
        destination: "#{scratch}/replace"
      , (err, written) ->
        '#A config file\n#property=30\nproperty=50\n#End of Config'

  ###
  write: (options, callback) ->
    result = child mecano
    finish = (err, written) ->
      callback err, written if callback
      result.end err, written
    misc.options options, (err, options) ->
      return finish err if err
      written = 0
      each( options )
      .on 'item', (options, next) ->
        return next new Error 'Missing source or content' unless (options.source or options.content?) or options.replace
        return next new Error 'Define either source or content' if options.source and options.content
        return next new Error 'Missing destination' unless options.destination
        destination  = null
        destinationHash = null
        content = fullContent = null
        from = to = null
        append = options.append
        readSource = ->
          if options.content?
            content = options.content
            return extractPartial()
          # Option "local_source" force to bypass the ssh 
          # connection, use by the upload function
          options.source ?= options.destination
          ssh = if options.local_source then null else options.ssh
          misc.file.exists ssh, options.source, (err, exists) ->
            return next err if err
            unless exists
              content = ''
              return extractPartial()
            misc.file.readFile ssh, options.source, (err, src) ->
              return next err if err
              content = src
              extractPartial()
        extractPartial = ->
          return readDestination() unless options.from? or options.to? or options.match?
          # from = if options.from then content.indexOf(options.from) + options.from.length else 0
          # to = if options.to then content.indexOf(options.to) else content.length
          fullContent = content
          content = options.replace
          readDestination()
        readDestination = ->
          # no need to test changes if destination is a callback
          return render() if typeof options.destination is 'function'
          misc.file.exists options.ssh, options.destination, (err, exists) ->
            return render() unless exists
            misc.file.readFile options.ssh, options.destination, (err, dest) ->
              return next err if err
              destinationHash = misc.string.hash dest
              render()
        render = ->
          return replacePartial() unless options.context?
          try
            content = eco.render content.toString(), options.context
          catch err then return next err
          replacePartial()
        replacePartial = ->
          return writeContent() unless fullContent?
          if options.match
            if options.match instanceof RegExp
              # content is options.replace, may be a string or an array
              content = fullContent.replace options.match, content
              if append and typeof options.replace is 'string'
                # If we find a match, we dont append so we disable the append flag
                if options.match.test fullContent
                  append = false
                # If we dont find a match, we append so we key the append flag and set the new content
                else
                  content = if content.length is 0 or content.substr(content.length - 1) is '\n' then '' else '\n'
                  content += options.replace
            else
              from = fullContent.indexOf(options.match)
              to = from + options.match.length
              content = fullContent.substr(0, from) + content + fullContent.substr(to)
          else
            from = if options.from then fullContent.indexOf(options.from) + options.from.length else 0
            to = if options.to then fullContent.indexOf(options.to) else fullContent.length
            content = fullContent.substr(0, from) + content + fullContent.substr(to)
          fullContent = null
          writeContent()
        writeContent = ->
          return next() if destinationHash is misc.string.hash content
          if typeof options.destination is 'function'
            options.destination content
            next()
          else
            options.flags ?= 'a' if append
            misc.file.writeFile options.ssh, options.destination, content, options, (err) ->
              return next err if err
              written++
              backup()
        backup = ->
          return next() unless options.backup
          backup = options.backup
          backup = ".#{Date.now()}" if backup is true
          backup = "#{options.destination}#{backup}"
          misc.file.writeFile options.ssh, backup, content, (err) ->
            return next err if err
            next()
        conditions.all options, next, readSource
      .on 'both', (err) ->
        finish err, written
    result

# Alias definitions

mecano.cp   = mecano.copy
mecano.exec = mecano.execute
mecano.ln   = mecano.link
mecano.mv   = mecano.move
mecano.rm   = mecano.remove


