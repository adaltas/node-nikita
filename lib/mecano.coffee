
fs = require 'fs'
path = require 'path'
util = require 'util'
each = require 'each'
eco = require 'eco'
rimraf = require 'rimraf'
exec = require('child_process').exec
open = require 'open-uri'

conditions = require './conditions'
misc = require './misc'

###

Mecano gather a set of functions usually used during system deployment. All the functions share a 
common API with flexible options.

###
mecano = module.exports = 
    ###

    `cp` `copy(options, callback)` Copy a file
    ------------------------------------------

    `options`               Command options includes:   

    *   `source`            The file or directory to copy.
    *   `destination`       Where the file or directory is copied.
    *   `force`             Copy the file even if one already exists.
    *   `not_if_exists`     Equals destination if true.
    *   `chmod`             Permissions of the file or the parent directory

    `callback`              Received parameters are:   

    *   `err`               Error object if any.   
    *   `copied`            Number of files or parent directories copied.

    todo:
    *   deal with directories
    *   preserve permissions if `chmod` is `true`
    *   Compare files with checksum

    ###
    copy: (options, callback) ->
        options = misc.options options
        copied = 0
        each( options )
        .on 'item', (next, options) ->
            return next new Error 'Missing source' unless options.source
            return next new Error 'Missing destination' unless options.destination
            options.not_if_exists = options.destination if options.not_if_exists is true
            dstStat = null
            source = ->
                fs.stat options.source, (err, stat) ->
                    # Source does not exists or any error occured
                    return next err if err
                    return next new Error 'Source is a directory' if stat.isDirectory()
                    copy()
            copy = (destination = options.destination) ->
                fs.stat destination, (err, stat) ->
                    dstStat = stat
                    return next err if err and err.code isnt 'ENOENT'
                    # do not copy if destination exists
                    dirExists = not err and stat.isDirectory()
                    fileExists = not err and stat.isFile()
                    return next null, 0 if fileExists and not options.force
                    # Update destination name and call copy again
                    return copy path.resolve options.destination, path.basename(options.source) if dirExists
                    # Copy
                    input = fs.createReadStream options.source
                    output = fs.createWriteStream destination
                    util.pump input, output, (err) ->
                        return next err if err
                        chmod()
            chmod = ->
                return finish() if not options.chmod or options.chmod is dstStat.mode
                fs.chmod options.destination, options.chmod, (err) ->
                    return next err if err
                    finish()
            finish = ->
                copied++
                next()
            conditions.all(options, next, copy)
        .on 'both', (err) ->
            callback err, copied
    ###

    `download(options, callback)` Download files using various protocols
    --------------------------------------------------------------------

    The excellent [open-uri](https://github.com/publicclass/open-uri) module provides support for HTTP(S), 
    file and FTP. All the options supported by open-uri are passed to it.

    Note, GIT is not yet supported but documented as a wished feature.

    `options`               Command options includes:   

    *   `source`            File, HTTP URL, FTP, GIT repository. File is the default protocol if source is provided without a scheme.   
    *   `destination`       Path where the file is downloaded.   
    *   `force`             Overwrite destination file if it exists.   

    `callback`              Received parameters are:   

    *   `err`               Error object if any.   
    *   `downloaded`        Number of downloaded files

    Basic example:
        mecano.download
            source: 'https://github.com/wdavidw/node-sigar/tarball/v0.0.1'
            destination: 'node-sigar.tgz'
        , (err, downloaded) ->
            path.exists 'node-sigar.tgz', (exists) ->
                assert.ok exists
    
    ###
    download: (options, callback) ->
        options = misc.options options
        downloaded = 0
        each( options )
        .on 'item', (next, options) ->
            return next new Error "Missing source: #{options.source}" unless options.source
            return next new Error "Missing destination: #{options.destination}" unless options.destination
            options.force ?= false
            download = () ->
                destination = fs.createWriteStream(options.destination)
                open(options.source, destination)
                destination.on 'close', () ->
                    downloaded++
                    next()
                destination.on 'error', (err) ->
                    next err
            path.exists options.destination, (exists) ->
                # Use previous download
                if exists and not options.force
                    return next()
                # Remove previous dowload and download again
                else if exists
                    return rimraf options.destination, (err) ->
                        return next err if err
                        download()
                else download()
        .on 'both', (err) ->
            callback err, downloaded
    ###

    `exec` `execute`([goptions], options, callback)` Run a command locally or with ssh
    ----------------------------------------------------------------------------------
    Command is send over ssh if the `host` is provided. Global options is
    optional and is used in case where options is defined as an array of 
    multiple commands. Note, `opts` inherites all the properties of `goptions`.

    `goptions`              Global options includes:

    *   `parallel`          Wether the command are run in sequential, parallel 
    or limited concurrent mode. See the `node-each` documentation for more 
    details. Default to sequential (false).
                
    `options`               Include all conditions as well as:  

    *   `cmd`               String, Object or array; Command to execute.   
    *   `env`               Environment variables, default to `process.env`.   
    *   `cwd`               Current working directory.   
    *   `uid`               Unix user id.   
    *   `gid`               Unix group id.   
    *   `code`              Expected code(s) returned by the command, int or array of int, default to 0.   
    *   `host`              SSH host or IP address.   
    *   `username`          SSH host or IP address.   
    *   `stdout`            Writable EventEmitter in which command output will be piped.   
    *   `stderr`            Writable EventEmitter in which command error will be piped.   

    `callback`              Received parameters are:   

    *   `err`               Error if any.   
    *   `executed`          Number of executed commandes.   
    *   `stdout`            Stdout value(s) unless `stdout` option is provided.   
    *   `stderr`            Stderr value(s) unless `stderr` option is provided.   

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
        .on 'item', (next, option, i) ->
            option = { cmd: option } if typeof option is 'string'
            misc.merge true, option, goptions
            return next new Error "Missing cmd: #{option.cmd}" unless option.cmd?
            option.code ?= [0]
            option.code = [option.code] unless Array.isArray option.code
            cmdOption = {}
            cmdOption.env = option.env or process.env
            cmdOption.cwd = option.cwd or null
            cmdOption.uid = option.uid if options.uid
            cmdOption.gid = option.gid if options.gid
            cmd = () ->
                if option.host
                    option.cmd = escape option.cmd
                    option.cmd = option.host + ' "' + option.cmd + '"'
                    if option.username
                        option.cmd = option.username + '@' + option.cmd
                    option.cmd = 'ssh -o StrictHostKeyChecking=no ' + option.cmd
                run = exec option.cmd, cmdOption
                stdout = stderr = ''
                if option.stdout
                then run.stdout.pipe option.stdout
                else run.stdout.on 'data', (data) -> stdout += data
                if option.stderr
                then run.stderr.pipe option.stderr
                else run.stderr.on 'data', (data) -> stderr += data
                run.on "exit", (code) ->
                    executed++
                    stdouts.push if option.stdout then undefined else stdout
                    stderrs.push if option.stderr then undefined else stderr
                    if option.code.indexOf(code) is -1
                        err = new Error "Invalid exec code #{code}"
                        err.code = code
                        return next err
                    next()
            # if option.not_if_exists
            #     path.exists option.not_if_exists, (exists) ->
            #         if exists then next() else cmd()
            # else
            #     cmd()
            conditions.all(option, next, cmd)
        .on 'both', (err) ->
            stdouts = stdouts[0] unless isArray
            stderrs = stderrs[0] unless isArray
            callback err, executed, stdouts, stderrs
    ###

    `extract(options, callback)` Extract an archive
    -----------------------------------------------

    Multiple compression types are supported. Unless specified as 
    an option, format is derived from the source extension. At the 
    moment, supported extensions are '.tgz', '.tar.gz' and '.zip'.   

    `options`               Command options includes:   

    *   `source`            Archive to decompress.   
    *   `destination`       Default to the source parent directory.   
    *   `format`            One of 'tgz' or 'zip'.   
    *   `creates`           Ensure the given file is created or an error is send in the callback.   
    *   `not_if_exists`     Cancel extraction if file exists.   

    `callback`              Received parameters are:   

    *   `err`               Error object if any.   
    *   `extracted`         Number of extracted archives.   

    ###
    extract: (options, callback) ->
        options = misc.options options
        extracted = 0
        each( options )
        .on 'item', (next, options) ->
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
                exec cmd, (err, stdout, stderr) ->
                    return next err if err
                    creates()
            # Step for `creates`
            creates = () ->
                return success() unless options.creates?
                path.exists options.creates, (exists) ->
                    return next new Error "Failed to create '#{path.basename options.creates}'" unless exists
                    success()
            # Final step
            success = () ->
                extracted++
                next()
            conditions.all(options, next, extract)
        .on 'both', (err) ->
            callback err, extracted
    ###
    
    `git`
    ---------

    `options`               Command options includes:   

    *   `source`            Git source repository address.
    *   `destination`       Directory where to clone the repository.
    *   `revision`          Git revision, branch or tag.
    
    ###
    git: (options, callback) ->
        options = misc.options options
        updated = 0
        each( options )
        .on 'item', (next, options) ->
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
                    #cmd: "git init && git remote add origin #{options.source} && git branch --track master origin/master && git pull"
                    cmd: "git clone #{options.source} #{path.basename options.destination}"
                    cwd: path.dirname options.destination
                , (err, executed, stdout, stderr) ->
                    return next err if err
                    checkout()
            log = ->
                mecano.exec
                    cmd: "git log --pretty=format:'%H' -n 1"
                    cwd: options.destination
                , (err, executed, stdout, stderr) ->
                    return next err if err
                    current = stdout.trim()
                    mecano.exec
                        cmd: "git rev-list --max-count=1 #{options.revision}"
                        cwd: options.destination
                    , (err, executed, stdout, stderr) ->
                        return next err if err
                        if stdout.trim() isnt current
                        then checkout()
                        else next()
            checkout = ->
                mecano.exec
                    cmd: "git checkout #{options.revision}"
                    cwd: options.destination
                , (err) ->
                    return next err if err
                    updated++
                    next()
            new_rev = ->
            conditions.all options, next, prepare
        .on 'both', (err) ->
            callback err, updated

    ###

    `ln` `link(options, callback)` Create a symbolic link
    ------------------------------------------------

    `options`               Command options includes:   

    *   `source`            Referenced file to be linked.   
    *   `destination`       Symbolic link to be created.   
    *   `exec`              Create an executable file with an `exec` command.   
    *   `chmod`             Default to 0755.   

    `callback`              Received parameters are:   

    *   `err`               Error object if any.   
    *   `linked`            Number of created links.   

    ###
    link: (options, callback) ->
        options = misc.options options
        linked = 0
        sym_exists = (option, callback) ->
            path.exists option.destination, (exists) ->
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
            path.exists option.destination, (exists) ->
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
        each( options )
        .parallel( true )
        .on 'item', (next, option) ->
            return next new Error "Missing source, got #{JSON.stringify(option.source)}" unless option.source
            return next new Error "Missing destination, got #{JSON.stringify(option.destination)}" unless option.destination
            option.chmod ?= 0755
            if option.exec
                exec_exists option, (err, exists) ->
                    return next() if exists
                    exec_create option, next
            else
                sym_exists option, (err, exists) ->
                    return next() if exists
                    sym_create option, next
        .on 'both', (err) ->
            callback err, linked
    ###

    `mkdir(options, callback)` Recursively create a directory
    ---------------------------------------------------------

    The behavior is similar to the Unix command `mkdir -p`. It supports
    an alternative syntax where options is simply the path of the directory
    to create.

    `options`               Command options includes:   

    *   `source`            Path or array of paths.   
    *   `directory`         Shortcut for `source`
    *   `exclude`           Regular expression.   
    *   `chmod`             Default to 0755.    
    *   `cwd`               Current working directory for relative paths.   

    `callback`              Received parameters are:   

    *   `err`               Error object if any.   
    *   `created`           Number of created directories

    Simple usage:

        mecano.mkdir './some/dir', (err, created) ->
            console.log err?.message ? created

    ###
    mkdir: (options, callback) ->
        options = misc.options options
        created = 0
        each( options )
        .on 'item', (next, option) ->
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
                option.chmod ?= 0755
                current = ''
                dirCreated = false
                dirs = option.source.split '/'
                each( dirs )
                .on 'item', (next, dir) ->
                    # Directory name contains variables
                    # eg /\${/ on './var/cache/${user}' creates './var/cache/'
                    if option.exclude? and option.exclude instanceof RegExp
                        return next() if option.exclude.test dir
                    # Empty Dir caused by split
                    # ..commented because `resolve` should clean the path
                    # return next() if dir is ''
                    current += "/#{dir}"
                    # console.log current
                    path.exists current, (exists) ->
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

    `rm` `remove(options, callback)` Recursively remove a file or directory
    ------------------------------------------------------

    Internally, the function use the [rimraf](https://github.com/isaacs/rimraf) 
    library.

    `options`               Command options includes:   

    *   `source`            File or directory.     

    `callback`              Received parameters are:   

    *   `err`               Error object if any.   
    *   `deleted`           Number of deleted sources.   

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
        .on 'item', (next, options) ->
            options = source: options if typeof options is 'string'
            return next new Error 'Missing source: #{option.source}' unless options.source?
            # Use lstat instead of stat because it will report link presence
            fs.lstat options.source, (err, stat) ->
                return next() if err
                options.options ?= {}
                rimraf options.source, (err) ->
                    return next err if err
                    deleted++
                    next()
        .on 'both', (err) ->
            callback err, deleted
    ###

    `render(options, callback)` Render a template file
    --------------------------------------------------
    
    At the moment, only the [ECO](http://github.com/sstephenson/eco) templating engine is integrated.

    `options`               Command options includes:   

    *   `engine`            Template engine to use, default to "eco"
    *   `content`           Templated content, bypassed if source is provided.
    *   `source`            File path where to extract content from.
    *   `destination`       File path where to write content to.
    *   `context`           Map of key values to inject into the template.

    `callback`              Received parameters are:   

    *   `err`               Error object if any.   
    *   `rendered`          Number of rendered files.   

    ###
    render: (options, callback) ->
        options = misc.options options
        rendered = 0
        each( options )
        .on 'item', (next, option) ->
            return next new Error 'Missing source or content' unless option.source or option.content
            return next new Error 'Missing destination' unless option.destination
            readSource = ->
                return writeContent() unless option.source
                path.exists option.source, (exists) ->
                    return next new Error "Invalid source, got #{JSON.stringify(option.source)}" unless exists
                    fs.readFile option.source, (err, content) ->
                        return next err if err
                        option.content = content
                        writeContent()
            writeContent = ->
                try
                    content = eco.render option.content.toString(), option.context or {}
                    fs.writeFile option.destination, content, (err) ->
                        return next err if err
                        rendered++
                        next()
                catch err
                    next err
            readSource()
        .on 'both', (err) ->
            callback err, rendered

# Alias definitions

mecano.cp   = mecano.copy
mecano.exec = mecano.execute
mecano.ln   = mecano.link
mecano.rm   = mecano.remove


