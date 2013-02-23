
fs = require 'fs'
path = require 'path'
fs.exists ?= path.exists
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
    options = misc.options options
    copied = 0
    each( options )
    .on 'item', (options, next) ->
      return next new Error 'Missing source' unless options.source
      return next new Error 'Missing destination' unless options.destination
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
          fs.mkdir destination, (err) ->
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
      conditions.all(options, next, search)
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
    options = misc.options options
    downloaded = 0
    each( options )
    .on 'item', (options, next) ->
      return next new Error "Missing source: #{options.source}" unless options.source
      return next new Error "Missing destination: #{options.destination}" unless options.destination
      options.force ?= false
      prepare = () ->
        fs.exists options.destination, (exists) ->
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
        
  `options`         Include all conditions as well as:  

  *   `ssh`         SSH connection options or an ssh2 instance
  *   `cmd`         String, Object or array; Command to execute.   
  *   `env`         Environment variables, default to `process.env`.   
  *   `cwd`         Current working directory.   
  *   `uid`         Unix user id.   
  *   `gid`         Unix group id.   
  *   `code`        Expected code(s) returned by the command, int or array of int, default to 0.   
  *   `host`        SSH host or IP address.   
  *   `username`    SSH host or IP address.   
  *   `stdout`      Writable EventEmitter in which command output will be piped.   
  *   `stderr`      Writable EventEmitter in which command error will be piped.   

  `callback`        Received parameters are:   

  *   `err`         Error if any.   
  *   `executed`    Number of executed commandes.   
  *   `stdout`      Stdout value(s) unless `stdout` option is provided.   
  *   `stderr`      Stderr value(s) unless `stderr` option is provided.   

  ###
  execute: (goptions, options, callback) ->
    if arguments.length is 2
      callback = options
      options = goptions
    isArray = Array.isArray options
    options = misc.options options
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
    each( options )
    .parallel( goptions.parallel )
    .on 'item', (options, i, next) ->
      options = { cmd: options } if typeof options is 'string'
      misc.merge true, options, goptions
      return next new Error "Missing cmd: #{options.cmd}" unless options.cmd?
      options.code ?= [0]
      options.code = [options.code] unless Array.isArray options.code
      # cmdOptions = {}
      # cmdOptions.env = options.env or process.env
      # cmdOptions.cwd = options.cwd or null
      # cmdOptions.uid = options.uid if options.uid
      # cmdOptions.gid = options.gid if options.gid
      cmd = () ->
        # if options.host
        #   options.cmd = escape options.cmd
        #   options.cmd = options.host + ' "' + options.cmd + '"'
        #   if options.username
        #     options.cmd = options.username + '@' + options.cmd
        #   options.cmd = 'ssh -o StrictHostKeyChecking=no ' + options.cmd
        # run = exec options.cmd, cmdOptions
        run = exec options
        stdout = stderr = ''
        if options.stdout
        then run.stdout.pipe options.stdout
        else run.stdout.on 'data', (data) ->
          stdout += data
        if options.stderr
        then run.stderr.pipe options.stderr
        else run.stderr.on 'data', (data) -> stderr += data
        run.on "exit", (code) ->
          # Givent some time because the "exit" event is sometimes
          # called before the "stdout" "data" event when runing
          # `make test`
          setTimeout ->
            executed++
            stdouts.push if options.stdout then undefined else stdout
            stderrs.push if options.stderr then undefined else stderr
            if options.code.indexOf(code) is -1
              err = new Error "Invalid exec code #{code}"
              err.code = code
              return next err
            next()
          , 1
      conditions.all(options, next, cmd)
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

  `callback`            Received parameters are:   

  *   `err`             Error object if any.   
  *   `extracted`       Number of extracted archives.   

  ###
  extract: (options, callback) ->
    options = misc.options options
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
        fs.exists options.creates, (exists) ->
          return next new Error "Failed to create '#{path.basename options.creates}'" unless exists
          success()
      # Final step
      success = () ->
        extracted++
        next()
      # Run conditions
      if typeof options.should_exist is 'undefined'
        options.should_exist = options.source
      conditions.all(options, next, extract)
    .on 'both', (err) ->
      callback err, extracted
  ###
  
  `git`
  -----

  `options`             Command options include:   

  *   `ssh`             SSH connection options or an ssh2 instance
  *   `source`          Git source repository address.
  *   `destination`     Directory where to clone the repository.
  *   `revision`        Git revision, branch or tag.
  
  ###
  git: (options, callback) ->
    options = misc.options options
    updated = 0
    each( options )
    .on 'item', (options, next) ->
      options.revision ?= 'HEAD'
      rev = null
      prepare = ->
        fs.stat options.destination, (err, stat) ->
          return clone() if err and err.code is 'ENOENT'
          return next new Error "Destination not a directory, got #{options.destination}" unless stat.isDirectory()
          gitDir = "#{options.destination}/.git"
          fs.stat gitDir, (err, stat) ->
            return next err if err or not stat.isDirectory()
            log()
      clone = ->
        mecano.exec
          ssh: options.ssh
          cmd: "git clone #{options.source} #{path.basename options.destination}"
          cwd: path.dirname options.destination
        , (err, executed, stdout, stderr) ->
          return next err if err
          checkout()
      log = ->
        mecano.exec
          ssh: options.ssh
          cmd: "git log --pretty=format:'%H' -n 1"
          cwd: options.destination
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
    options = misc.options options
    linked = 0

    sym_exists = (option, callback) ->
      fs.exists option.destination, (exists) ->
        return callback null, false unless exists
        fs.readlink option.destination, (err, resolvedPath) ->
          return callback err if err
          return callback null, true if resolvedPath is option.source
          fs.unlink option.destination, (err) ->
            return callback err if err
            callback null, false
    sym_create = (option, callback) ->
      fs.symlink option.source, option.destination, (err) ->
        return callback err if err
        linked++
        callback()
    exec_exists = (option, callback) ->
      fs.exists option.destination, (exists) ->
        return callback null, false unless exists
        fs.readFile option.destination, 'ascii', (err, content) ->
          return callback err if err
          exec_cmd = /exec (.*) \$@/.exec(content)[1]
          callback null, exec_cmd and exec_cmd is option.source
    exec_create = (option, callback) ->
      content = """
      #!/bin/bash
      exec #{option.source} $@
      """
      fs.writeFile option.destination, content, (err) ->
        return callback err if err
        fs.chmod option.destination, option.chmod, (err) ->
          return callback err if err
          linked++
          callback()
    parents = for option in options then path.normalize path.dirname option.destination
    mecano.mkdir parents, (err, created) ->
      return callback err if err
      each( options )
      .parallel( true )
      .on 'item', (option, next) ->
        return next new Error "Missing source, got #{JSON.stringify(option.source)}" unless option.source
        return next new Error "Missing destination, got #{JSON.stringify(option.destination)}" unless option.destination
        option.chmod ?= 0o0755
        dispatch = ->
          if option.exec
            exec_exists option, (err, exists) ->
              return next() if exists
              exec_create option, next
          else
            sym_exists option, (err, exists) ->
              return next() if exists
              sym_create option, next
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
    options = misc.options options
    created = 0
    each( options )
    .on 'item', (option, next) ->
      option = { source: option } if typeof option is 'string'
      option.source = option.directory if not option.source? and option.directory?
      cwd = option.cwd ? process.cwd()
      option.source = path.resolve cwd, option.source
      return next new Error 'Missing source option' unless option.source?
      check = () ->
        # if exist and is a dir, skip
        # if exists and isn't a dir, error
        fs.stat option.source, (err, stat) ->
          return create() if err and err.code is 'ENOENT'
          return next err if err
          return next() if stat.isDirectory()
          next err 'Invalid source, got #{JSON.encode(option.source)}'
      create = () ->
        option.chmod ?= 0o0755
        current = ''
        dirCreated = false
        dirs = option.source.split '/'
        each( dirs )
        .on 'item', (dir, next) ->
          # Directory name contains variables
          # eg /\${/ on './var/cache/${user}' creates './var/cache/'
          if option.exclude? and option.exclude instanceof RegExp
            return next() if option.exclude.test dir
          # Empty Dir caused by split
          # ..commented because `resolve` should clean the path
          # return next() if dir is ''
          current += "/#{dir}"
          fs.exists current, (exists) ->
            return next() if exists
            fs.mkdir current, option.chmod, (err) ->
              return next err if err
              dirCreated = true
              next()
        .on 'both', (err) ->
          created++ if dirCreated
          next err
      check()
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
    options = misc.options options
    moved = 0
    each( options )
    .on 'item', (options, next) ->
      fs.rename options.source, options.destination, (err) ->
        return next err if err
        moved++
        next()
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
    options = misc.options options
    deleted = 0
    each( options )
    .on 'item', (options, next) ->
      options = source: options if typeof options is 'string'
      return next new Error 'Missing source: #{option.source}' unless options.source?
      options.options ?= {}
      each()
      .files(options.source)
      .on 'item', (file, next) ->
        deleted++
        rimraf file, next
      .on 'error', (err) ->
        next err
      .on 'end', ->
        next()
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
    options = misc.options options
    rendered = 0
    each( options )
    .on 'item', (option, next) ->
      return next new Error 'Missing source or content' unless option.source or option.content
      return next new Error 'Missing destination' unless option.destination
      readSource = ->
        return writeContent() unless option.source
        fs.exists option.source, (exists) ->
          return next new Error "Invalid source, got #{JSON.stringify(option.source)}" unless exists
          fs.readFile option.source, (err, content) ->
            return next err if err
            option.content = content
            writeContent()
      writeContent = ->
        mecano.write option, (err, written) ->
          return next err if err
          rendered++ if written
          next()
      readSource()
    .on 'both', (err) ->
      callback err, rendered
  ###
  `write(options, callback)`
  --------------------------

  Write a file or a portion of an existing file.
  
  `options`           Command options include:   
  
  *   `from`          Replace from after this marker, a string or a regular expression matching a line
  *   `to`            Replace to before this marker, a string or a regular expression matching a line
  *   `content`       Text to be written.
  *   `destination`   File path where to write content to.

  `callback`          Received parameters are:   
  
  *   `err`           Error object if any.   
  *   `rendered`      Number of rendered files. 

  ###
  write: (options, callback) ->
    options = misc.options options
    written = 0
    each( options )
    .on 'item', (option, next) ->
      return next new Error 'Missing source or content' unless option.source or option.content
      return next new Error 'Missing destination' unless option.destination
      destination  = null
      destinationHash = null
      readDestinationContent = ->
        # no need to test changes if destination is a callback
        return writeContent() if typeof option.destination is 'function'
        fs.exists option.destination, (exists) ->
          return writeContent() unless exists
          fs.readFile option.destination, (err, content) ->
            return next err if err
            # destination = content if from or to
            destinationHash = misc.string.hash content
            writeContent()
      writeContent = ->
        try content = eco.render option.content.toString(), option.context or {}
        catch err then return next err
        return next() if destinationHash is misc.string.hash content
        if typeof option.destination is 'function'
          option.destination content
          next()
        else 
          fs.writeFile option.destination, content, (err) ->
            return next err if err
            written++
            next()
      readDestinationContent()
    .on 'both', (err) ->
      callback err, written
  ###
  `service(options, callback)`
  ----------------------------
  ###
  service: (options, callback) ->
    options = misc.options options
    written = 0
    each( options )
    .on 'item', (option, next) ->
      return next new Error 'Missing service name' unless option.name
      # installed = ->
      #   ctx.ssh.exec 'yum list installed | grep ^httpd\\\\.', (err, stream) ->
      #     return next err if err
      #     stream.on 'exit', (code, signal) ->
      #       return next ctx.SKIPPED if code is 0
      #       install()
      # install = ->
      #   ctx.ssh.exec 'yum install -y httpd', (err, stream) ->
      #     return next err if err
      #     stream.on 'exit', (code, signal) ->
      #       next ctx.OK unless ctx.config.httpd.start
      #       startup()
      # startup = ->
      #   return start unless ctx.config.startup
      #   if ctx.config.startup
      #     cmd = 'chkconfig httpd --add; chkconfig httpd on --level 2,3,5'
      #   else 
      #     cmd = 'chkconfig httpd off; chkconfig httpd --del'
      #   ctx.ssh.exec cmd, (err, stream) ->
      #     return next err if err
      #     stream.on 'exit', (code, signal) ->
      #       start()
      # start = ->
      #   ctx.ssh.exec 'service httpd start', (err, stream) ->
      #     return next err if err
      #     stream.on 'exit', (code, signal) ->
      #       next ctx.OK
    .on 'both', (err) ->
      callback err, written

# Alias definitions

mecano.cp   = mecano.copy
mecano.exec = mecano.execute
mecano.ln   = mecano.link
mecano.mv   = mecano.move
mecano.rm   = mecano.remove


