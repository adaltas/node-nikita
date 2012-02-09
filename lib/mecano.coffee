
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
        options = [options] unless Array.isArray options
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

    `extract(options, callback)` Extract an archive
    -----------------------------------------------

    Multiple compression types are supported. Unless specified as 
    an option, format is derived from the source extension. At the 
    moment, supported extensions are '.tgz', '.tar.gz' and '.zip'.

    `options`               Command options includes:   

    *   `source`            Archive to decompress
    *   `destination`       Default to the source parent directory
    *   `format`            One of 'tgz' or 'zip'
    *   `creates`           Ensure the given file is created or an error is send in the callback.
    *   `not_if_exists`     Cancel extraction if file exists

    `callback`              Received parameters are:   

    *   `err`               Error object if any
    *   `extracted`         Number of extracted archives

    ###
    extract: (options, callback) ->
        options = [options] unless Array.isArray options
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
                    return next new Error 'Failed at creating expected file, manual cleanup is required' unless exists
                    success()
            # Final step
            success = () ->
                extracted++
                next()
            conditions.all(options, next, extract)
        .on 'both', (err) ->
            callback err, extracted
    ###

    Create a symbolic link
    ----------------------

    `options`               Command options includes:   

    *   `source`            Referenced file to be linked
    *   `destination`       Symbolic link to be created
    *   `exec`              Create an executable file with an `exec` command
    *   `chmod`             Default to 0755

    `callback`              Received parameters are:   

    *   `err`               Error object if any
    *   `linked`            Number of created links

    ###
    link: (options, callback) ->
        options = [options] unless Array.isArray options
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
    Render a template file
    ----------------------
    
    At the moment, we have only integrated the ECO templating engine.

    `options`               Command options includes:   

    *   content             
    *   source              
    *   destination         
    *   context             

    `callback`              Received parameters are:   

    ###
    render: (options, callback) ->
        options = [options] unless Array.isArray options
        rendered = 0
        each( options )
        .on 'item', (next, option) ->
            return next new Error 'Missing source or content' unless option.source or option.content
            return next new Error 'Missing destination' unless option.destination
            writeContent = ->
                try
                    content = eco.render option.content.toString(), option.context or {}
                    fs.writeFile option.destination, content, (err) ->
                        return next err if err
                        rendered++
                        next()
                catch err
                    next err
            readSource = ->
                return writeContent() unless option.source
                path.exists option.source, (exists) ->
                    return next new Error "Invalid source, got #{JSON.stringify(option.source)}" unless exists
                    fs.readFile option.source, (err, content) ->
                        return next err if err
                        option.content = content
                        writeContent()
            readSource()
        .on 'both', (err) ->
            callback err, rendered
    
    ###

    `copy(options, callback)`: Copy a file or a directory
    -----------------------------------------------------

    `options`               Command options includes:   

    *   source              
    *   destination         
    *   not_if_exists              Equals destination if true
    *   chmod               

    `callback`              Received parameters are:   

    ###
    copy: (options, callback) ->
        return callback new Error 'Missing source' unless options.source
        return callback new Error 'Missing destination' unless options.destination
        options.destination = path.normalize options.destination
        options.not_if_exists = options.destination if options.not_if_exists is true
        options.not_if_exists = path.normalize options.not_if_exists if options.not_if_exists
        fs.stat options.destination, (err, dstStat) ->
            unless err
                if options.not_if_exists and options.not_if_exists is options.destination
                    return chmod dstStat
                else
                    # todo, we should check md5
                    return callback null, 0
            path.exists options.source, (exists) ->
                return callback new Error 'Source does not exists' unless exists
                input = fs.createReadStream options.source
                output = fs.createWriteStream options.destination
                util.pump input, output, (err) ->
                    return callback err if err
                    chmod dstStat
        chmod = (dstStat) ->
            return callback null, 1 if not options.chmod or options.chmod is dstStat.mode
            fs.chmod options.destination, options.chmod, (err) ->
                callback err, 1
    ###

    `mkdir`: Create a directory and its parent if necessary
    -------------------------------------------------------------

    The behavior is similar to the Unix command `mkdir -p`

    `options`               Command options includes:   

    *   `directory`         Path or array of paths
    *   `exclude`           Regexp
    *   `chmod`             Default to 0755

    `callback`              Received parameters are:   

    *   `err`
    *   `created`           Number of created directories

    ###
    mkdir: (options, callback) ->
        options = [options] unless Array.isArray options
        created = 0
        each( options )
        .on 'item', (next, option) ->
            option = { directory: option } if typeof option is 'string'
            return next new Error 'Missing directory option' unless option.directory?
            check = () ->
                fs.stat option.directory, (err, stat) ->
                    return create() if err and err.code is 'ENOENT'
                    return next err if err
                    return next() if stat.isDirectory()
                    next err 'Invalid source, got #{JSON.encode(option.directory)}'
                # if exist and is a dir, skip
                # if exists and isn't a dir, error
            create = () ->
                option.chmod ?= 0755
                tmpDirs = option.directory.split '/'
                tmpDirCreate = ''
                dirCreated = false
                each( tmpDirs )
                .on 'item', (next, tmpDir) ->
                    # Directory name contains variables
                    # eg /\${/ on './var/cache/${user}' creates './var/cache/'
                    if option.exclude? and option.exclude instanceof RegExp
                        return next() if option.exclude.test tmpDir
                    # Empty Dir caused by split
                    return next() if tmpDir is ''
                    tmpDirCreate += "/#{tmpDir}"
                    path.exists tmpDirCreate, (exists) ->
                        return next() if exists
                        fs.mkdir tmpDirCreate, option.chmod, (err) ->
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

    `remove`, `rm`: Recursively remove a file or directory
    ------------------------------------------------------

    Internally, the function use the unmissable 
    [rimraf][https://github.com/isaacs/rimraf] library.

    `options`               Command options includes:   

    *   `source`            File or directory
    *   `options`           Options passed to rimraf

    `callback`              Received parameters are:   

    *   `err`               
    *   `deleted`           Number of deleted sources

    Exemple

        mecano.rm './some/dir', (err, removed) ->
            console.log "#{removed} dir removed"
    
    Removing a direcotry unless a given file exists
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
        options = [options] unless Array.isArray options
        deleted = 0
        each( options )
        .on 'item', (next, options) ->
            options = source: options if typeof options is 'string'
            return next new Error 'Missing source: #{option.source}' unless options.source?
            # Use lstat instead of stat because it will report link presence
            fs.lstat options.source, (err, stat) ->
                return next() if err
                options.options ?= {}
                rimraf options.source, options.options, (err) ->
                    return next err if err
                    deleted++
                    next()
        .on 'both', (err) ->
            callback err, deleted
    ###

    `exec([goptions], options, callback)`: Run a command locally or with ssh
    ------------------------------------------------------------------
    Command is send over ssh if the `host` is provided. Global options is
    optional and is used in case where options is defined as an array of 
    multiple commands. Note, `opts` inherites all the properties of `goptions`.

    `goptions`              Global options includes:

    *   `parallel`          Wether the command are run in sequential, parallel 
    or limited concurrent mode. See the `node-each` documentation for more 
    details. Default to sequential (false).
                
    `options`               Command options includes:   

    *   `cmd`               String, Object or array; Command to execute
    *   `code`              Expected code returned by the command, default to 0.
    *   `not_if_exists`     Dont run the command if the file exists
    *   `host`              SSH host or IP address.
    *   `username`          SSH host or IP address.
    *   `stdout`            Writable EventEmitter in which command output will be piped.
    *   `stderr`            Writable EventEmitter in which command error will be piped.

    `callback`              Received parameters are:   

    *   `err`               Error if any
    *   `executed`          Number of executed commandes
    *   `stdout`            Stdout value(s) unless `stdout` option is provided
    *   `stderr`            Stderr value(s) unless `stderr` option is provided

    ###
    exec: (goptions, options, callback) ->
        if arguments.length is 2
            callback = options
            options = goptions
        isArray = Array.isArray options
        options = [options] unless isArray
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
            option.code ?= 0
            cmdOption = {}
            cmdOption.cwd = option.cwd if option.cwd
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
                    stdouts.push if option.stdout then null else stdout
                    stderrs.push if option.stderr then null else stderr
                    if code isnt option.code
                        err = new Error 'Failed to execute command'
                        err.code = code
                        return next err
                    next()
            if option.not_if_exists
                path.exists option.not_if_exists, (exists) ->
                    if exists then next() else cmd()
            else
                cmd()
        .on 'both', (err) ->
            stdouts = stdouts[0] unless isArray
            stderrs = stderrs[0] unless isArray
            callback err, executed, stdouts, stderrs

# Alias definitions

mecano.cp = mecano.copy
mecano.ln = mecano.link
mecano.rm = mecano.remove


