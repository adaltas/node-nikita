
fs = require 'fs'
path = require 'path'
util = require 'util'
each = require 'each'
eco = require 'eco'
rimraf = require 'rimraf'
exec = require('child_process').exec
open = require 'open-uri'

mecano = 
    
    ###
    Download a file using various protocols
    ---------------------------------------

    The excellent [open-uri][https://github.com/publicclass/open-uri] module provide support for HTTP(S), 
    file and FTP. All the options supported by open-uri are passed to it.

    Note, GIT is not yet supported but documented as a wished feature.

    Options are   
    *   source      , File, HTTP URL, FTP, GIT repository. File is the default
                      protocol if source is provided without a scheme.   
    *   destination , Path where the file is downloaded.   
    *   force       , Overwrite destination file if it exists.   

    Callback parameters are   
    *   err         , Error object if any.   
    *   downloaded  , Number of downloaded files

    ###

    download: (options, callback) ->
        return callback new Error "Missing source: #{options.source}" unless options.source
        return callback new Error "Missing destination: #{options.destination}" unless options.destination
        options.force ?= false
        download = () ->
            destination = fs.createWriteStream(options.destination)
            open(options.source, destination)
            destination.on 'close', () ->
                callback null, 1
            destination.on 'error', (err) ->
                callback err
        path.exists options.destination, (exists) ->
            # Use previous download
            if exists and not options.force
                return callback null, 0
            # Remove previous dowload and download again
            else if exists
                return rimraf options.destination, (err) ->
                    return callback err if err
                    download()
            else download()
    
    ###

    Extract an archive, support multiple compression types
    ------------------------------------------------------

    Unless specified as an option, format is derived from the 
    source extension. At the moment, upported extensions are 
    '.tgz', '.tar.gz' and '.zip'.

    Options are
    *   source      , Archive to decompress
    *   destination , Default to the source parent directory
    *   format      , One of 'tgz' or 'zip'
    *   creates     , Ensure the given file is created or an error is send in the callback.
    *   not_if      , Cancel extraction if file exists

    Callback parameters are
    *   err         , Error object if any
    *   extracted   , Number of extracted archives

    ###

    extract: (options, callback) ->
        return callback new Error "Missing source: #{options.source}" unless options.source
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
                return callback new Error "Unsupported extension, got #{JSON.stringify(ext)}"
        # Step for `not_if`
        not_if = () ->
            return extract() unless options.not_if?
            path.exists options.not_if, (exists) ->
                return callback null, 0 if exists
                extract()
        # Working step
        extract = () ->
            cmd = null
            switch format
                when 'tgz' then cmd = "tar xzf #{options.source} -C #{destination}"
                when 'zip' then cmd = "unzip -u #{options.source} -d #{destination}"
            exec cmd, (err, stdout, stderr) ->
                return callback err if err
                creates()
        # Step for `creates`
        creates = () ->
            return callback null, 1 unless options.creates?
            path.exists options.creates, (exists) ->
                return callback new Error 'Failed at creating expected file, manual cleanup is required' unless exists
                callback null, 1
        not_if()
    
    ###

    Create a symbolic link
    ----------------------

    Options are
    *   source      , Referenced file to be linked
    *   destination , Symbolic link to be created
    *   exec        , Create an executable file with an `exec` command
    *   chmod       , Default to 0755

    Callback parameters are
    *   err         , Error object if any
    *   linked      , Number of created links

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

    Options are
    *   content     ,
    *   source      ,
    *   destination , 
    *   context     ,

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
    Copy a file
    Options are
    *   source      , 
    *   destination , 
    *   not_if      , Equals destination if true
    *   chmod       , 
    ###
    copy: (options, callback) ->
        return callback new Error 'Missing source' unless options.source
        return callback new Error 'Missing destination' unless options.destination
        options.destination = path.normalize options.destination
        options.not_if = options.destination if options.not_if is true
        options.not_if = path.normalize options.not_if if options.not_if
        fs.stat options.destination, (err, dstStat) ->
            unless err
                if options.not_if and options.not_if is options.destination
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

    Options are
    *   directory   , Path or array of paths
    *   exclude     , Regexp
    *   chmod       , Default to 0755
    Callback parameters are
    *   err
    *   created     , Number of created directories
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

    Options are
    *   source      , File or directory
    *   options     , Options passed to rimraf

    Callback parameters are
    *   err
    *   deleted     , Number of deleted sources

    Exemple

        mecano.rm __dirname, (err, removed) ->
            console.log "#{removed} dir removed"
        
        mecano.rm
            source: __dirname
            not_if: __filename
        , (err, removed) ->
            console.log "#{removed} dir removed"
        
        mecano.rm [
            { source: __dirname, not_if: __filename }
            process.cwd()
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
    Options are
    *   cmd     , String, Object or array; Command to execute
    *   not_if  , Dont run the command if the file exists
    Callback parameters are
    *   err
    *   executed     , Number of executed commandes
    ###
    exec: (options, callback) ->
        options = [options] unless Array.isArray options
        executed = 0
        each( options )
        .on 'item', (next, option) ->
            option = { cmd: option } if typeof option is 'string'
            return next new Error 'Missing cmd: #{option.cmd}' unless option.cmd?
            cmdOption = {}
            cmdOption.cwd = option.cwd if option.cwd
            cmd = () ->
                exec option.cmd, cmdOption, (err, stdout, stderr) ->
                    return next err if err
                    executed++
                    next()
            if option.not_if
                path.exists option.not_if, (exists) ->
                    if exists then next() else cmd()
            else
                cmd()
        .on 'both', (err) ->
            callback err, executed
    
    isPortOpen: (port, host, callback) ->
        if arguments.length is 2
            callback = host
            host = '127.0.0.1'
        exec "nc #{host} #{port} < /dev/null", (err, stdout, stdout) ->
            return callback null, true unless err
            return callback null, false if err.code is 1
            callback err

# Alias definitions

mecano.cp = mecano.copy
mecano.ln = mecano.link
mecano.rm = mecano.remove

module.exports = mecano

