
fs = require 'fs'
path = require 'path'
util = require 'util'
each = require 'each'
eco = require 'eco'
rimraf = require 'rimraf'
open = require 'open-uri'
exec = require 'superexec'

conditions = require './conditions'
misc = require './misc'

###

Mecano gather a set of functions usually used during system deployment. All the functions share a 
common API with flexible options.

###
mecano = module.exports = 
  ###

  `cp` `copy(options, callback)`
  ------------------------------

  Copy a file. The behavior is similar to the one of the `cp` 
  Unix utility. Copying a file over an existing file will 
  overwrite it.

  `options`         Command options include:   

  *   `source`      The file or directory to copy.
  *   `destination`     Where the file or directory is copied.
  *   `not_if_exists`   Equals destination if true.
  *   `chmod`       Permissions of the file or the parent directory

  `callback`        Received parameters are:   

  *   `err`         Error object if any.   
  *   `copied`      Number of files or parent directories copied.

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

  Download files using various protocols. The excellent 
  [open-uri](https://github.com/publicclass/open-uri) module provides support for HTTP(S), 
  file and FTP. All the options supported by open-uri are passed to it.

  Note, GIT is not yet supported but documented as a wished feature.

  `options`         Command options include:   

  *   `source`      File, HTTP URL, FTP, GIT repository. File is the default protocol if source is provided without a scheme.   
  *   `destination` Path where the file is downloaded.   
  *   `force`       Overwrite destination file if it exists.   

  `callback`        Received parameters are:   

  *   `err`         Error object if any.   
  *   `downloaded`  Number of downloaded files

  Basic example:
      mecano.download
        source: 'https://github.com/wdavidw/node-sigar/tarball/v0.0.1'
        destination: 'node-sigar.tgz'
      , (err, downloaded) ->
        fs.exists 'node-sigar.tgz', (exists) ->
          assert.ok exists
  
  ###
  download: (options, callback) ->
    misc.options options, (err, options) ->
      return callback err if err
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
              rimraf options.destination, (err) ->
                return next err if err
                download()
            else download()
        download = () ->
          destination = fs.createWriteStream(options.destination)
          open(options.source, destination)
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
        callback err, downloaded
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
  *   `host`          SSH host or IP address.   
  *   `username`      SSH host or IP address.   
  *   `ssh`           SSH connection options or an ssh2 instance   
  *   `stdout`        Writable EventEmitter in which command output will be piped.   
  *   `stderr`        Writable EventEmitter in which command error will be piped.   

  `callback`        Received parameters are:   

  *   `err`         Error if any.   
  *   `executed`    Number of executed commandes.   
  *   `stdout`      Stdout value(s) unless `stdout` option is provided.   
  *   `stderr`      Stderr value(s) unless `stderr` option is provided.   

  ###
  execute: (options, callback) ->
    isArray = Array.isArray options
    misc.options options, (err, options) ->
      return callback err if err
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
      stds = callback.length > 2
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
          stdout = stderr = ''
          if options.stdout
            run.stdout.pipe options.stdout
          if stds
            run.stdout.on 'data', (data) ->
              stdout += data
          if options.stderr
            run.stderr.pipe options.stderr
          if stds
            run.stderr.on 'data', (data) ->
              stderr += data
          run.on "exit", (code) ->
            # Givent some time because the "exit" event is sometimes
            # called before the "stdout" "data" event when runing
            # `make test`
            setTimeout ->
              stdouts.push if stds then stdout else undefined
              stderrs.push if stds then stderr else undefined
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
        callback err, executed, stdouts, stderrs
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
  *   `ssh`             SSH connection options or an ssh2 instance     

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
  *   `ssh`             SSH connection options or an ssh2 instance.   
  *   `stdout`      Writable EventEmitter in which command output will be piped.   
  *   `stderr`      Writable EventEmitter in which command error will be piped.   
  
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
    misc.options options, (err, options) ->
      return callback err if err
      created = 0
      each( options )
      .on 'item', (options, next) ->
        options = { source: options } if typeof options is 'string'
        options.source = options.directory if not options.source? and options.directory?
        cwd = options.cwd ? process.cwd()
        options.source = path.resolve cwd, options.source
        return next new Error 'Missing source option' unless options.source?
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
              misc.file.mkdir options.ssh, current, options.chmod, (err) ->
                return next err if err
                dirCreated = true
                next()
          .on 'both', (err) ->
            created++ if dirCreated
            next err
        conditions.all options, next, check
      .on 'both', (err) ->
        callback err, created
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

  `callback`        Received parameters are:   

  *   `err`         Error object if any.   
  *   `deleted`     Number of deleted sources.   

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
    misc.options options, (err, options) ->
      return callback err if err
      deleted = 0
      each( options )
      .on 'item', (options, next) ->
        options = source: options if typeof options is 'string'
        return next new Error "Missing source: #{options.source}" unless options.source?
        options.options ?= {}
        remove = ->
          each()
          .files(options.source)
          .on 'item', (file, next) ->
            deleted++
            rimraf file, next
          .on 'error', (err) ->
            next err
          .on 'end', ->
            next()
        conditions.all options, next, remove
      .on 'both', (err) ->
        callback err, deleted
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
          misc.file.exists options.ssh, options.source, (err, exists) ->
            return next new Error "Invalid source, got #{JSON.stringify(options.source)}" unless exists
            misc.file.readFile options.ssh, options.source, (err, content) ->
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
  `write(options, callback)`
  --------------------------

  Write a file or a portion of an existing file.
  
  `options`           Command options include:   
  
  *   `from`          Replace from after this marker, a string or a regular expression matching a line.
  *   `to`            Replace to before this marker, a string or a regular expression matching a line.
  *   `content`       Text to be written.
  *   `source`        File path from where to extract the content, do not use conjointly with content.
  *   `destination`   File path where to write content to.
  *   `backup`        Create a backup, append a provided string to the filename extension or a timestamp if value is not a string.

  `callback`          Received parameters are:   
  
  *   `err`           Error object if any.   
  *   `rendered`      Number of rendered files. 

  ###
  write: (options, callback) ->
    misc.options options, (err, options) ->
      return callback err if err
      written = 0
      each( options )
      .on 'item', (options, next) ->
        return next new Error 'Missing source or content' unless options.source or options.content
        return next new Error 'Define either source or content' if options.source and options.content
        return next new Error 'Missing destination' unless options.destination
        destination  = null
        destinationHash = null
        source = null
        readSource = ->
          if options.content
            source = options.content
            return readDestination()
          # Option "local_source" force to bypass the ssh 
          # connection, use by the upload function
          ssh = if options.local_source then null else options.ssh
          misc.file.readFile ssh, options.source, (err, content) ->
            source = content
            readDestination()
        readDestination = ->
          # no need to test changes if destination is a callback
          return render() if typeof options.destination is 'function'
          misc.file.exists options.ssh, options.destination, (err, exists) ->
            return render() unless exists
            misc.file.readFile options.ssh, options.destination, (err, content) ->
              return next err if err
              # destination = content if from or to
              destinationHash = misc.string.hash content
              render()
        render = ->
          return writeContent() unless options.context?
          try
            source = eco.render source.toString(), options.context
          catch err then return next err
          writeContent()
        writeContent = ->
          return next() if destinationHash is misc.string.hash source
          if typeof options.destination is 'function'
            options.destination source
            next()
          else
            misc.file.writeFile options.ssh, options.destination, source, (err) ->
              return next err if err
              written++
              backup()
        backup = ->
          return next() unless options.backup
          backup = options.backup
          backup = ".#{Date.now()}" if backup is true
          backup = "#{options.destination}#{backup}"
          misc.file.writeFile options.ssh, backup, source, (err) ->
            return next err if err
            next()
        conditions.all options, next, readSource
      .on 'both', (err) ->
        callback err, written
  ###
  `service(options, callback)`
  ----------------------------

  Install a service. For now, only yum over SSH.
  
  `options`             Command options include:   

  *    name             Package name.
  *    startup          Run service daemon on startup.
  *    yum_name         Name used by the yum utility, default to "name".
  *    chk_name         Name used by the chkconfig utility, default to "name".
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
        chkname = options.chk_name or options.name
        srvname = options.srv_name or options.name
        if options.startup? and typeof options.startup isnt 'string'
            options.startup = if options.startup then '235' else ''
        modified = false
        installed = ->
          mecano.execute
            ssh: options.ssh
            cmd: "yum list installed | grep ^#{pkgname}\\\\."
            code_skipped: 1
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
            # console.log 'startup', options.startup, current_startup
            return started() if options.startup is current_startup
            modified = true
            startup()
        startup = ->
          startup_on = startup_off = ''
          for i in [0...6]
            if options.startup.indexOf(i) isnt -1
              startup_on += i
            else
              startup_off += i

          if options.startup
            cmd = "chkconfig --add #{chkname}; chkconfig --level #{options.startup} #{chkname} on"
          else 
            cmd = "chkconfig #{chkname} off; chkconfig --del #{chkname}"
          console.log 'cmd', cmd
          mecano.execute
            ssh: options.ssh
            cmd: cmd
          , (err, stream) ->
            return next err if err
            started()
        started = ->
          return finish() unless options.start? and options.stop?
          mecano.execute
            ssh: options.ssh
            cmd: "service #{srvname} status"
            code_skipped: 3
          , (err, started) ->
            return next err if err
            start = if options.start? then options.start else options.stop
            if not started and start then start()
            if started and not start then stop()
            else finish()
        start = ->
          return finish() unless options.start?
          cmd = if options.start then 'start' else 'stop'
          mecano.execute
            ssh: options.ssh
            cmd: "service #{srvname} #{cmd}"
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
  *   `from`          Replace from after this marker, a string or a regular expression matching a line.
  *   `to`            Replace to before this marker, a string or a regular expression matching a line.
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

# Alias definitions

mecano.cp   = mecano.copy
mecano.exec = mecano.execute
mecano.ln   = mecano.link
mecano.mv   = mecano.move
mecano.rm   = mecano.remove


