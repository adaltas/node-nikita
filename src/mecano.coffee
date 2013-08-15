
fs = require 'fs'
path = require 'path'
url = require 'url'
util = require 'util'
each = require 'each'
eco = require 'eco'
exec = require 'superexec'
request = require 'request'
ini = require 'ini'
Ftp = require 'jsftp'
ldap = require 'ldapjs'
ldap_client = require 'ldapjs/lib/client/client'
{EventEmitter} = require 'events'

conditions = require './conditions'
misc = require './misc'
child = require './child'
curl = require './curl'

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

  `options`           Command options include:   

  *   `source`        The file or directory to copy.
  *   `destination`   Where the file or directory is copied.
  *   `not_if_exists` Equals destination if true.
  *   `mode`          Permissions of the file or the parent directory
  *   `ssh`           Run the action on a remote server using SSH, an ssh2 instance or an configuration object used to initialize the SSH connection.   
 
  `callback`          Received parameters are:   

  *   `err`           Error object if any.   
  *   `copied`        Number of files or parent directories copied.

  todo:
  *   preserve permissions if `mode` is `true`

  ###
  copy: (options, callback) ->
    misc.options options, (err, options) ->
      return callback err if err
      copied = 0
      each( options )
      .on 'item', (options, next) ->
        # Validate parameters
        return next new Error 'Missing source' unless options.source
        return next new Error 'Missing destination' unless options.destination
        # return next new Error 'SSH not yet supported' if options.ssh
        # Cancel action if destination exists ? really ? no md5 comparaison, strange
        options.not_if_exists = options.destination if options.not_if_exists is true
        # Start real work
        search = ->
          srcStat = null
          dstStat = null
          misc.file.stat options.ssh, options.source, (err, stat) ->
            # Source must exists
            return next err if err
            srcStat = stat
            misc.file.stat options.ssh, options.destination, (err, stat) ->
              return next err if err and err.code isnt 'ENOENT'
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
            misc.file.stat options.ssh, source, (err, stat) ->
              return next err if err
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
            misc.file.compare options.ssh, [source, destination], (err, md5) ->
              # Destination may not exists
              return next err if err and err.message.indexOf('Does not exist') isnt 0
              # File are the same, we can skip copying
              return next() if md5
              # # Copy
              # input = fs.createReadStream source
              # output = fs.createWriteStream destination
              # input.pipe(output).on 'close', (err) ->
              #   return next err if err
              #   chmod source, next
              # Copy
              s = (ssh, callback) ->
                unless ssh
                then callback null, fs
                else options.ssh.sftp callback
              s options.ssh, (err, fs) ->
                  rs = fs.createReadStream source
                  ws = rs.pipe fs.createWriteStream destination
                  ws.on 'close', ->
                    fs.end() if fs.end
                    chmod source, next
                  ws.on 'error', next
          chmod = (file, next) ->
            return finish next if not options.mode or options.mode is dstStat.mode
            misc.file.chmod options.ssh, options.destination, options.mode, (err) ->
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

  When executed locally: the `http` protocol is handled 
  with the "request" module; the `ftp` protocol is handled 
  with the "jsftp"; the `file` protocol is handle with the navite 
  `fs` module.

  `options`           Command options include:   

  *   `source`        File, HTTP URL, FTP, GIT repository. File is the default protocol if source is provided without any.   
  *   `destination`   Path where the file is downloaded.   
  *   `force`         Overwrite destination file if it exists.   
  *   `stdout`        Writable Stream in which commands output will be piped.   
  *   `stderr`        Writable Stream in which commands error will be piped.   

  `callback`          Received parameters are:   

  *   `err`           Error object if any.   
  *   `downloaded`    Number of downloaded files

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
        # Validate parameters
        {destination, source, md5sum} = options
        return next new Error "Missing source: #{source}" unless source
        return next new Error "Missing destination: #{destination}" unless destination
        options.force ?= false
        stageDestination = "#{destination}.#{Date.now()}#{Math.round(Math.random()*1000)}"
        # Start real work
        prepare = () ->
          # Note about next line: ssh might be null with file, not very clear
          misc.file.exists options.ssh, destination, (err, exists) ->
            # Use previous download
            if exists and not options.force
              return next() unless md5sum
              misc.file.hash options.ssh, destination, 'md5', (err, hash) ->
                return next() if hash is md5sum
                misc.file.unlink options.ssh, destination, (err) ->
                  return next err if err
                  download()
            # Remove previous dowload and download again
            else if exists
              mecano.remove
                ssh: options.ssh
                destination: destination
              , (err) ->
                return next err if err
                download()
            else download()
        download = () ->
          u = url.parse source
          if options.ssh
            if u.protocol is 'http:'
              cmd = "curl #{source} -o #{stageDestination}"
              cmd += " -x #{options.proxy}" if options.proxy
              mecano.execute
                ssh: options.ssh
                cmd: cmd
                stdout: options.stdout
                stderr: options.stderr
              , (err, executed, stdout, stderr) ->
                return next curl.error err if err
                checksum()
            else if u.protocol is 'ftp:'
              return next new Error 'FTP download not supported over SSH'
            else
              options.ssh.sftp (err, sftp) ->
                return next err if err
                rs = sftp.createReadStream u.pathname
                ws = rs.pipe fs.createWriteStream stageDestination
                ws.on 'close', ->
                  # downloaded++ #unless err
                  checksum()
                ws.on 'error', next
          else
            ws = fs.createWriteStream(stageDestination)
            if u.protocol is 'http:'
              options.url = source
              request(options).pipe(ws)
            else if u.protocol is 'ftp:'
              options.host ?= u.hostname
              options.port ?= u.port
              if u.auth
                {user, pass} = u.auth.split ':'
              options.user ?= user
              options.pass ?= pass
              ftp = new Ftp options
              ftp.getGetSocket u.pathname, (err, rs) ->
                return next err if err
                rs.pipe ws
                rs.resume()
            else
              rs = fs.createReadStream(u.pathname)
              rs.pipe ws
            ws.on 'close', () ->
              checksum()
            ws.on 'error', (err) ->
              # No test agains this but error in case 
              # of connection issue leave an empty file
              mecano.remove ws, (err) ->
                next err
        checksum = ->
          return unstage() unless md5sum
          misc.file.hash options.ssh, stageDestination, 'md5', (err, hash) ->
            return unstage() if hash is md5sum
            # Download is invalid, cleaning up
            misc.file.remove options.ssh, stageDestination, (err) ->
              return next err if err
              next new Error "Invalid checksum, found \"#{hash}\" instead of \"#{md5sum}\""
        unstage = ->
          # Note about next line: ssh might be null with file, not very clear
          misc.file.rename options.ssh, stageDestination, destination, (err) ->
            return next err if err
            downloaded++
            next()
        prepare()
      .on 'both', (err) ->
        finish err, downloaded
  ###

  `exec` `execute([goptions], options, callback)`
  -----------------------------------------------
  Run a command locally or with ssh if `host` or `ssh` is provided.

  `options`           Command options include:   

  *   `cmd`           String, Object or array; Command to execute.   
  *   `env`           Environment variables, default to `process.env`.   
  *   `cwd`           Current working directory.   
  *   `uid`           Unix user id.   
  *   `gid`           Unix group id.   
  *   `code`          Expected code(s) returned by the command, int or array of int, default to 0.  
  *   `code_skipped`  Expected code(s) returned by the command if it has no effect, executed will not be incremented, int or array of int.   
  *   `stdout`        Writable Stream in which commands output will be piped.   
  *   `stderr`        Writable Stream in which commands error will be piped.   
  *   `ssh`           Run the action on a remote server using SSH, an ssh2 instance or an configuration object used to initialize the SSH connection.   

  `callback`          Received parameters are:   

  *   `err`           Error if any.   
  *   `executed`      Number of executed commandes.   
  *   `stdout`        Stdout value(s) unless `stdout` option is provided.   
  *   `stderr`        Stderr value(s) unless `stderr` option is provided.   

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
        # Validate parameters
        options = { cmd: options } if typeof options is 'string'
        return next new Error "Missing cmd: #{options.cmd}" unless options.cmd?
        options.code ?= [0]
        options.code = [options.code] unless Array.isArray options.code
        options.code_skipped ?= []
        options.code_skipped = [options.code_skipped] unless Array.isArray options.code_skipped
        # Start real work
        cmd = () ->
          run = exec options
          stdout = stderr = []
          if options.stdout
            run.stdout.pipe options.stdout, end: false
          if stds
            run.stdout.on 'data', (data) ->
              stdout.push data
          if options.stderr
            run.stderr.pipe options.stderr, end: false
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
              if options.stdout
                run.stdout.unpipe options.stdout
              if options.stderr
                run.stderr.unpipe options.stderr
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

  `options`           Command options include:   

  *   `source`        Archive to decompress.   
  *   `destination`   Default to the source parent directory.   
  *   `format`        One of 'tgz' or 'zip'.   
  *   `creates`       Ensure the given file is created or an error is send in the callback.   
  *   `not_if_exists` Cancel extraction if file exists.   
  *   `ssh`           Run the action on a remote server using SSH, an ssh2 instance or an configuration object used to initialize the SSH connection.   

  `callback`          Received parameters are:   

  *   `err`           Error object if any.   
  *   `extracted`     Number of extracted archives.   

  ###
  extract: (options, callback) ->
    misc.options options, (err, options) ->
      return callback err if err
      extracted = 0
      each( options )
      .on 'item', (options, next) ->
        # Validate parameters
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
        # Start real work
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

  `options`           Command options include:   

  *   `source`        Git source repository address.   
  *   `destination`   Directory where to clone the repository.   
  *   `revision`      Git revision, branch or tag.   
  *   `ssh`           Run the action on a remote server using SSH, an ssh2 instance or an configuration object used to initialize the SSH connection.   
  *   `stdout`        Writable EventEmitter in which command output will be piped.   
  *   `stderr`        Writable EventEmitter in which command error will be piped.   
  
  ###
  git: (options, callback) ->
    misc.options options, (err, options) ->
      return callback err if err
      updated = 0
      each( options )
      .on 'item', (options, next) ->
        # Sanitize parameters
        options.revision ?= 'HEAD'
        rev = null
        # Start real work
        prepare = ->
          misc.file.exists options.ssh, options.destination, (err, exists) ->
            return next err if err
            return clone() unless exists
            # return next new Error "Destination not a directory, got #{options.destination}" unless stat.isDirectory()
            gitDir = "#{options.destination}/.git"
            misc.file.exists options.ssh, gitDir, (err, exists) ->
              return next new Error "Not a git repository" unless exists
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
              stdout: options.stdout
              stderr: options.stderr
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

  `ini(options, callback`
  -----------------------
  Write an object as .ini file. Note, we are internally using the
  [ini](https://github.com/isaacs/ini) module. However, there is 
  a subtile difference. Any key provided with value of `undefined` 
  or `null` will be disregarded. Within a `merge`, it get more prowerfull
  and tricky: the original value will be kept if `undefined` is provided 
  while the value will be removed if `null` is provided.

  The `ini` function rely on the `write` function and accept all of its 
  options. It introduces the `merge` option which instruct to read the
  destination file if it exists and merge its parsed object with the one
  provided in the `content` option.

  `options`           Command options include:   

  *   `append`        Append the content to the destination file. If destination does not exist, the file will be created. When used with the `match` and `replace` options, it will append the `replace` value at the end of the file if no match if found and if the value is a string.   
  *   `backup`        Create a backup, append a provided string to the filename extension or a timestamp if value is not a string.   
  *   `content`       Object to stringify.   
  *   `stringify`     User defined function to stringify to ini format, default to `require('ini').stringify`.   
  *   `destination`   File path where to write content to or a callback.   
  *   `from`          Replace from after this marker, a string or a regular expression.   
  *   `local_source`  Treat the source as local instead of remote, only apply with "ssh" option.   
  *   `match`         Replace this marker, a string or a regular expression.   
  *   `merge`         Read the destination if it exists and merge its content.   
  *   `replace`       The content to be inserted, used conjointly with the from, to or match options.   
  *   `source`        File path from where to extract the content, do not use conjointly with content.   
  *   `ssh`           Run the action on a remote server using SSH, an ssh2 instance or an configuration object used to initialize the SSH connection.   
  *   `to`            Replace to before this marker, a string or a regular expression.   
  
  ###
  ini: (options, callback) ->
    clean = (content, undefinedOnly) ->
      for k, v of content
        if v and typeof v is 'object'
          content[k] = clean v, undefinedOnly
          continue
        delete content[k] if typeof v is 'undefined'
        delete content[k] if not undefinedOnly and v is null
      content
    result = child mecano
    finish = (err, written) ->
      callback err, written if callback
      result.end err, written
    misc.options options, (err, options) ->
      return finish err if err
      written = 0
      each( options )
      .on 'item', (options, next) ->
        {merge, destination, content, ssh} = options
        # Validate parameters
        return next new Error 'Missing content' unless content
        return next new Error 'Missing destination' unless destination
        # Start real work
        get = ->
          return write() unless merge
          misc.file.exists ssh, destination, (err, exists) ->
            return next err if err
            return write() unless exists
            misc.file.readFile ssh, destination, 'ascii', (err, c) ->
              return next err if err and err.code isnt 'ENOENT'
              content = clean content, true
              content = misc.merge ini.parse(c), content
              write()
        write = ->
          clean content
          stringify = options.stringify or ini.stringify
          options.content = stringify content
          mecano.write options, (err, w) ->
            written += w
            next err
        get()
      .on 'both', (err) ->
        finish err, written
    result

  ###
  
  `ldap_acl(options, callback`
  ----------------------------

  `options`           Command options include:   

  *   `to`            What to control access to as a string.   
  *   `by`            Who to grant access to and the access to grant as an array (eg: `{..., by:["ssf=64 anonymous auth"]}`)   
  *   `url`           Specify URI referring to the ldap server, alternative to providing an [ldapjs client] instance.  
  *   `binddn`        Distinguished Name to bind to the LDAP directory, alternative to providing an [ldapjs client] instance.  
  *   `passwd`        Password for simple authentication, alternative to providing an [ldapjs client] instance.   
  *   `ldap`          Instance of an pldapjs client][ldapclt], alternative to providing the `url`, `binddn` and `passwd` connection properties.   
  *   `unbind`        Close the ldap connection, default to false if connection is an [ldapjs client][ldapclt] instance.   
  *   `name`          Distinguish name storing the "olcAccess" property, using the database adress (eg: "olcDatabase={2}bdb,cn=config").   
  *   `overwrite`     Overwrite existing "olcAccess", default is to merge.   

  Resources:
  http://www.openldap.org/doc/admin24/access-control.html

  [ldapclt]: http://ldapjs.org/client.html
  ###
  ldap_acl: (options, callback) ->
    result = child mecano
    finish = (err, modified) ->
      callback err, modified if callback
      result.end err, modified
    misc.options options, (err, options) ->
      return finish err if err
      modified = 0
      each( options )
      .on 'item', (options, next) ->
        client = null
        updated = false
        options.to = options.to.trim()
        for b, i in options.by
          options.by[i] = b.trim()
        connect = ->
          if options.ldap instanceof ldap_client
            client = options.ldap
            return search()
          # Open and bind connection
          client = ldap.createClient url: options.url
          client.bind options.binddn, options.passwd, (err) ->
            return end err if err
            search()
        search = ->
            # ctx.log 'Search attribute olcAccess'
            client.search options.name,
              scope: 'base'
              attributes: ['olcAccess']
            , (err, search) ->
              return unbind err if err
              olcAccess = null
              search.on 'searchEntry', (entry) ->
                # ctx.log "Found #{JSON.stringify entry.object}"
                # typeof olcAccess may be undefined, array or string
                olcAccess = entry.object.olcAccess or []
                olcAccess = [olcAccess] unless Array.isArray olcAccess
              search.on 'end', ->
                # ctx.log "Attribute olcAccess was #{JSON.stringify olcAccess}"
                parse olcAccess
        parse = (_olcAccess) ->
          olcAccess = []
          for access, i in _olcAccess
            to = ''
            bys = []
            buftype = 0 # 0: start, 1: to, 2:by
            buf = ''
            for c, i in access
              buf += c
              if buftype is 0
                if /to$/.test buf
                  buf = ''
                  buftype = 1
              if buftype is 1
                if matches = /^(.*)by$/.exec buf
                  to = matches[1].trim()
                  buf = ''
                  buftype = 2
              if buftype is 2
                if matches = /^(.*)by$/.exec buf
                  bys.push matches[1].trim()
                  buf = ''
                else if i+1 is access.length
                  bys.push buf.trim()
            olcAccess.push
              to: to
              by: bys
          diff olcAccess
        diff = (olcAccess) ->
          toAlreadyExist = false
          for access, i in olcAccess
            continue unless options.to is access.to
            toAlreadyExist = true
            fby = unless options.overwrite then access.by else []
            for oby in options.by
              found = false
              for aby in access.by
                if oby is aby
                  found = true
                  break
              unless found
                updated = true
                fby.push oby 
            olcAccess[i].by = fby
          unless toAlreadyExist
            updated = true
            # place before
            if options.before
              found = null
              for access, i in olcAccess
                found = i if access.to is options.before
              throw new Error 'Before does not match any "to" rule' unless found?
              olcAccess.splice i-1, 0, to: options.to, by: options.by
            # place after
            else if options.before
              found = false
              for access, i in olcAccess
                found = i if access.to is options.after
              throw new Error 'After does not match any "to" rule'
              olcAccess.splice i, 0, to: options.to, by: options.by
            # append
            else
              olcAccess.push to: options.to, by: options.by
          if updated then stringify(olcAccess) else unbind()
        stringify = (olcAccess) ->
          for access, i in olcAccess
            value = "{#{i}}to #{access.to}"
            for bie in access.by
              value += " by #{bie}"
            olcAccess[i] = value
          save olcAccess
        save = (olcAccess) ->
          change = new ldap.Change 
            operation: 'replace'
            modification: olcAccess: olcAccess
          client.modify options.name, change, (err) ->
            unbind err
        unbind = (err) ->
          # ctx.log 'Unbind connection'
          # return end err unless options.unbind and options.ldap instanceof ldap_client
          return end err if options.ldap instanceof ldap_client and not options.unbind
          client.unbind (e) ->
            return next e if e
            end err
        end = (err) ->
          modified += 1 if updated and not err
          next err
        conditions.all options, next, connect
      .on 'both', (err) ->
        finish err, modified
    result
  ###

  `ldap_index(options, callback`
  ------------------------------

  `options`           Command options include:   

  *   `indexes`       Object with keys mapping to indexed attributes and values mapping to indices ("pres", "approx", "eq", "sub" and 'special').   
  *   `url`           Specify URI referring to the ldap server, alternative to providing an [ldapjs client] instance.  
  *   `binddn`        Distinguished Name to bind to the LDAP directory, alternative to providing an [ldapjs client] instance.  
  *   `passwd`        Password for simple authentication, alternative to providing an [ldapjs client] instance.   
  *   `ldap`          Instance of an pldapjs client][ldapclt], alternative to providing the `url`, `binddn` and `passwd` connection properties.   
  *   `unbind`        Close the ldap connection, default to false if connection is an [ldapjs client][ldapclt] instance.   
  *   `name`          Distinguish name storing the "olcAccess" property, using the database adress (eg: "olcDatabase={2}bdb,cn=config").   
  *   `overwrite`     Overwrite existing "olcAccess", default is to merge.   
  
  Resources
  http://www.zytrax.com/books/ldap/apa/indeces.html
  ###
  ldap_index: (options, callback) ->
    result = child mecano
    finish = (err, created) ->
      callback err, created if callback
      result.end err, created
    misc.options options, (err, options) ->
      return finish err if err
      modified = 0
      each( options )
      .on 'item', (options, next) ->
        client = null
        updated = false
        connect = ->
          if options.ldap instanceof ldap_client
            client = options.ldap
            return get()
          # Open and bind connection
          client = ldap.createClient url: options.url
          client.bind options.binddn, options.passwd, (err) ->
            return end err if err
            get()
        get = ->
          client.search 'olcDatabase={2}bdb,cn=config', 
              scope: 'base'
              attributes: ['olcDbIndex']
          , (err, search) ->
            olcDbIndex = null
            search.on 'searchEntry', (entry) ->
              olcDbIndex = entry.object.olcDbIndex
            search.on 'end', ->
              parse olcDbIndex
        parse = (arIndex) ->
          indexes = {}
          for index in arIndex
            [k,v] = index.split ' '
            indexes[k] = v
          diff indexes
        diff = (orgp) ->
          unless options.overwrite
            newp = misc.merge {}, orgp, options.indexes
          else
            newp = options.indexes
          okl = Object.keys(orgp).sort()
          nkl = Object.keys(newp).sort()
          for i in [0...Math.min(okl.length, nkl.length)]
            if i is okl.length or i is nkl.length or okl[i] isnt nkl[i] or orgp[okl[i]] isnt newp[nkl[i]]
              updated = true
              break
          if updated then stringifiy newp else unbind()
        stringifiy = (perms) ->
          indexes = []
          for k, v of perms
            indexes.push "#{k} #{v}"
          replace indexes
        replace = (indexes) ->
          change = new ldap.Change
            operation: 'replace'
            modification: 
              olcDbIndex: indexes
          client.modify options.name, change, (err) ->
            unbind err
        unbind = (err) ->
          return end err if options.ldap instanceof ldap_client and not options.unbind
          client.unbind (e) ->
            return next e if e
            end err
        end = (err) ->
          modified += 1 if updated and not err
          next err
        conditions.all options, next, connect
      .on 'both', (err) ->
        finish err, modified
    result

  ###
  Register a new ldap schema
  --------------------------

  `options`           Command options include:   

  *   `url`           Specify URI referring to the ldap server, alternative to providing an [ldapjs client] instance.  
  *   `binddn`        Distinguished Name to bind to the LDAP directory, alternative to providing an [ldapjs client] instance.  
  *   `passwd`        Password for simple authentication, alternative to providing an [ldapjs client] instance.   
  *   `name`          Common name of the schema.   
  *   `schema`        Path to the schema definition.   
  *   `overwrite`     Overwrite existing "olcAccess", default is to merge.   
  *   `log`           Output channel to print mecano specific log information.   
  ###
  ldap_schema: (options, callback) ->
    result = child mecano
    finish = (err, created) ->
      callback err, created if callback
      result.end err, created
    misc.options options, (err, options) ->
      return finish err if err
      modified = 0
      each( options )
      .on 'item', (options, next) ->
        return next new Error "Missing name" unless options.name
        return next new Error "Missing schema" unless options.schema
        options.schema = options.schema.trim()
        tempdir = options.tempdir or "/tmp/mecano_ldap_schema_#{Date.now()}"
        schema = "#{tempdir}/#{options.name}.schema"
        conf = "#{tempdir}/schema.conf"
        ldif = "#{tempdir}/ldif"
        registered = ->
          options.log 'Check if schema is registered'
          mecano.execute
            cmd: "ldapsearch  -D #{options.binddn} -w #{options.passwd} -b \"cn=schema,cn=config\" | grep -E cn=\\{[0-9]+\\}#{options.name},cn=schema,cn=config"
            code: 0
            code_skipped: 1
            ssh: options.ssh
            stdout: options.stdout
            stderr: options.stderr
          , (err, registered, stdout) ->
            return next err if err
            return next() if registered
            dir()
        dir = ->
          options.log 'Create ldif directory'
          mecano.mkdir
            destination: ldif
            ssh: options.ssh
          , (err, executed) ->
            return next err if err
            write()
        write = ->
          options.log 'Copy schema'
          mecano.copy
            source: options.schema
            destination: schema
            ssh: options.ssh
          , (err, copied) ->
            return next err if err
            options.log 'Prepare configuration'
            mecano.write
              content: "include         #{options.schema}"
              destination: conf
              ssh: options.ssh
            , (err) ->
              return next err if err
              generate()
        generate = ->
          options.log 'Generate configuration'
          mecano.execute
            cmd: "slaptest -f #{conf} -F #{ldif}"
            ssh: options.ssh
            stdout: options.stdout
            stderr: options.stderr
          , (err, executed) ->
            return next err if err
            rename()
        rename = ->
          options.log 'Rename configuration'
          mecano.move
            source: "#{ldif}/cn=config/cn=schema/cn={0}#{options.name}.ldif"
            destination: "#{ldif}/cn=config/cn=schema/cn=#{options.name}.ldif"
            force: true
            ssh: options.ssh
          , (err, moved) ->
            return next err if err
            return new Error 'No generated schema' unless moved
            configure()
        configure = ->
          options.log 'Prepare ldif'
          mecano.write
            destination: "#{ldif}/cn=config/cn=schema/cn=#{options.name}.ldif"
            write: [
              match: /^dn: cn.*$/mg
              replace: "dn: cn=#{options.name},cn=schema,cn=config"
            ,
              match: /^cn: {\d+}(.*)$/mg
              replace: 'cn: $1'
            ,
              match: /^structuralObjectClass.*/mg
              replace: ''
            ,
              match: /^entryUUID.*/mg
              replace: ''
            ,
              match: /^creatorsName.*/mg
              replace: ''
            ,
              match: /^createTimestamp.*/mg
              replace: ''
            ,
              match: /^entryCSN.*/mg
              replace: ''
            ,
              match: /^modifiersName.*/mg
              replace: ''
            ,
              match: /^modifyTimestamp.*/mg
              replace: ''
            ]
            ssh: options.ssh
          , (err, written) ->
            return next err if err
            register()
        register = ->
          options.log 'Add schema'
          mecano.execute
            cmd: "ldapadd -f #{ldif}/cn=config/cn=schema/cn=#{options.name}.ldif -D cn=admin,cn=config -w test"
            ssh: options.ssh
            stdout: options.stdout
            stderr: options.stderr
          , (err, executed) ->
            return next err if err
            modified++
            clean()
        clean = ->
          options.log 'Clean up'
          mecano.remove
            destination: tempdir
            ssh: options.ssh
          , (err, removed) ->
            next err
        conditions.all options, next, registered
      .on 'both', (err) ->
        finish err, modified
    result

  ###

  `ln` `link(options, callback)`
  ------------------------------
  Create a symbolic link and it's parent directories if they don't yet
  exist.

  `options`           Command options include:   

  *   `source`        Referenced file to be linked.   
  *   `destination`   Symbolic link to be created.   
  *   `exec`          Create an executable file with an `exec` command.   
  *   `mode`          Default to 0755.   

  `callback`          Received parameters are:   

  *   `err`           Error object if any.   
  *   `linked`        Number of created links.   

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
          misc.file.readFile options.ssh, options.destination, 'utf8', (err, content) ->
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
          fs.chmod options.destination, options.mode, (err) ->
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
          options.mode ?= 0o0755
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
  *   `uid`           Unix user id.   
  *   `gid`           Unix group id.  
  *   `directory`     Alias for `source`
  *   `destination`   Alias for `source`
  *   `exclude`       Regular expression.   
  *   `mode`          Default to 0755.  
  *   `cwd`           Current working directory for relative paths.   

  `callback`          Received parameters are:   

  *   `err`           Error object if any.   
  *   `created`       Number of created directories

  Simple usage:

      mecano.mkdir './some/dir', (err, created) ->
        console.log err?.message ? created

  Advance usage:

      mecano.mkdir 
        ssh: options.ssh
        destination: './some/dir'
        uid: 'me'
        gid: 'my_group'
        mode: 0o0777 or '777'

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
        # Validate parameters
        options = { source: options } if typeof options is 'string'
        options.source ?= options.directory
        options.source ?= options.destination
        return next new Error 'Missing source option' unless options.source?
        cwd = options.cwd ? process.cwd()
        options.source = path.resolve cwd, options.source
        # Start real work
        check = () ->
          misc.file.stat options.ssh, options.source, (err, stat) ->
            return create() if err and err.code is 'ENOENT'
            return next err if err
            # nothing to do if exist and is a dir
            return next() if stat.isDirectory()
            # error if exists and isn't a dir
            next err 'Invalid source, got #{JSON.encode(options.source)}'
        create = () ->
          options.mode ?= 0o0755
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

  Move files and directories.   

  `options`           Command options include:   
  
  *   `destination`   Final name of the moved resource.   
  *   `force`         Overwrite the destination if it exists.   
  *   `source`        File or directory to move.   
  
  `callback`          Received parameters are:   
  
  *   `err`           Error object if any.   
  *   `moved`         Number of moved resources.

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
        # Start real work
        exists = ->
          misc.file.stat options.ssh, options.destination, (err, stat) ->
            return move() if err?.code is 'ENOENT'
            return next err if err
            return next new Error 'Destination already exists, use the force option' unless options.force
            remove()
        remove = ->
          mecano.remove
            ssh: options.ssh
            destination: options.destination
          , (err, removed) ->
            return next err if err
            move()
        move = ->
          misc.file.rename options.ssh, options.source, options.destination, (err) ->
            return next err if err
            moved++
            next()
        conditions.all options, next, exists
      .on 'both', (err) ->
        callback err, moved
  ###

  `rm` `remove(options, callback)`
  --------------------------------

  Recursively remove files, directories and links. Internally, the function 
  use the [rimraf](https://github.com/isaacs/rimraf) library.

  `options`           Command options include:   
  
  *   `source`        File, directory or pattern.  
  *   `destination`   Alias for "source". 
  
  `callback`          Received parameters are:   
  
  *   `err`           Error object if any.   
  *   `removed`       Number of removed sources.   

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
        # Validate parameters
        options = source: options if typeof options is 'string'
        options.source ?= options.destination
        return next new Error "Missing source" unless options.source?
        # Start real work
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
        # Validate parameters
        return next new Error 'Missing source or content' unless options.source or options.content
        return next new Error 'Missing destination' unless options.destination
        # Start real work
        readSource = ->
          return writeContent() unless options.source
          ssh = if options.local_source then null else options.ssh
          misc.file.exists ssh, options.source, (err, exists) ->
            return next new Error "Invalid source, got #{JSON.stringify(options.source)}" unless exists
            misc.file.readFile ssh, options.source, 'utf8', (err, content) ->
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
  
  `options`           Command options include:   

  *   `name`          Package name.   
  *   `startup`       Run service daemon on startup. If true, startup will be set to '2345', use an empty string to not define any run level.   
  *   `yum_name`      Name used by the yum utility, default to "name".   
  *   `chk_name`      Name used by the chkconfig utility, default to "srv_name" and "name".   
  *   `srv_name`      Name used by the service utility, default to "name".   
  #   `start`         Ensure the service is started, a boolean.   
  #   `stop`          Ensure the service is stopped, a boolean.   
  *   `action`        Execute the service with the provided action argument.
  *   `stdout`        Writable Stream in which commands output will be piped.   
  *   `stderr`        Writable Stream in which commands error will be piped.   
  *   `installed`     Cache a list of installed services. If an object, the service will be installed if a key of the same name exists; if anything else (default), no caching will take place.   
  *   `updates`       Cache a list of outdated services. If an object, the service will be updated if a key of the same name exists; If true, the option will be converted to an object with all the outdated service names as keys; if anything else (default), no caching will take place.   
  
  `callback`          Received parameters are:   
  
  *   `err`           Error object if any.   
  *   `modified`      Number of action taken (installed, updated, started or stoped).   
  *   `installed`     List of installed services.   
  *   `updates`       List of services to update.   

  ###
  service: (options, callback) ->
    installed = updates = null
    misc.options options, (err, options) ->
      return callback err if err
      serviced = 0
      each( options )
      .on 'item', (options, next) ->
        # Validate parameters
        return next new Error 'Missing service name' unless options.name
        return next new Error 'Restricted to Yum over SSH' unless options.ssh
        # return next new Error 'Invalid configuration, start conflict with stop' if options.start? and options.start is options.stop
        pkgname = options.yum_name or options.name
        chkname = options.chk_name or options.srv_name or options.name
        srvname = options.srv_name or options.name
        if options.startup? and typeof options.startup isnt 'string'
            options.startup = if options.startup then '2345' else ''
        modified = false
        installed ?= options.installed
        updates ?= options.updates
        # Start real work
        chkinstalled = ->
          cache = ->
            mecano.execute
              ssh: options.ssh
              cmd: "yum list installed"
              code_skipped: 1
              stdout: options.stdout
              stderr: options.stderr
            , (err, executed, stdout) ->
              return next err if err
              stdout = stdout.split '\n'
              start = false
              installed = []
              for pkg in stdout
                start = true if pkg.trim() is 'Installed Packages'
                continue unless start
                installed.push pkg[1] if pkg = /^([^\. ]+?)\./.exec pkg
              decide()
          decide = ->
            if installed.indexOf(pkgname) isnt -1 then chkupdates() else install()
          if installed then decide() else cache()
          # mecano.execute
          #   ssh: options.ssh
          #   cmd: "yum list installed | grep ^#{pkgname}\\\\."
          #   code_skipped: 1
          #   stdout: options.stdout
          #   stderr: options.stderr
          # , (err, installed) ->
          #   return next err if err
          #   if installed then updates() else install()
        chkupdates = ->
          cache = ->
            mecano.execute
              ssh: options.ssh
              cmd: "yum list updates"
              code_skipped: 1
              stdout: options.stdout
              stderr: options.stderr
            , (err, executed, stdout) ->
              return next err if err
              stdout = stdout.split '\n'
              start = false
              updates = []
              for pkg in stdout
                start = true if pkg.trim() is 'Updated Packages'
                continue unless start
                updates.push pkg[1] if pkg = /^([^\. ]+?)\./.exec pkg
              decide()
          decide = ->
            if updates.indexOf(pkgname) isnt -1 then install() else startuped()
          if updates then decide() else cache()
          # mecano.execute
          #   ssh: options.ssh
          #   cmd: "yum list updates | grep ^#{pkgname}\\\\."
          #   code_skipped: 1
          #   stdout: options.stdout
          #   stderr: options.stderr
          # , (err, outdated) ->
          #   return next err if err
          #   if outdated then install() else startuped()
        install = ->
          mecano.execute
            ssh: options.ssh
            cmd: "yum install -y #{pkgname}"
            code_skipped: 1
            stdout: options.stdout
            stderr: options.stderr
          , (err, succeed) ->
            return next err if err
            installedIndex = installed.indexOf pkgname
            installed.push pkgname if installedIndex is -1
            if updates
              updatesIndex = updates.indexOf pkgname
              updates.splice updatesIndex, 1 unless updatesIndex is -1
            # Those 2 lines seems all wrong
            return next new Error "No package #{pkgname} available." unless succeed
            modified = true if installed
            startuped()
        startuped = ->
          return started() unless options.startup?
          mecano.execute
            ssh: options.ssh
            cmd: "chkconfig --list #{chkname}"
            code_skipped: 1
            stdout: options.stdout
            stderr: options.stderr
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
            if options.startup?
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
            stdout: options.stdout
            stderr: options.stderr
          , (err, stream) ->
            return next err if err
            started()
        startup_del = ->
          mecano.execute
            ssh: options.ssh
            cmd: "chkconfig --del #{chkname}"
            stdout: options.stdout
            stderr: options.stderr
          , (err, stream) ->
            return next err if err
            started()
        started = ->
          return action() if options.action isnt 'start' and options.action isnt 'stop'
          mecano.execute
            ssh: options.ssh
            cmd: "service #{srvname} status"
            code_skipped: 3
            stdout: options.stdout
            stderr: options.stderr
          , (err, started) ->
            return next err if err
            if started
              return action() unless options.action is 'start'
            else
              return action() unless options.action is 'stop'
            finish() 
        action = ->
          return finish() unless options.action
          mecano.execute
            ssh: options.ssh
            cmd: "service #{srvname} #{options.action}"
            stdout: options.stdout
            stderr: options.stderr
          , (err, executed) ->
            return next err if err
            modified = true
            finish()
        finish = ->
          serviced++ if modified
          next()
        conditions.all options, next, chkinstalled
      .on 'both', (err) ->
        callback err, serviced, installed, updates
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
    result = child mecano
    finish = (err, uploaded) ->
      callback err, uploaded if callback
      result.end err, uploaded
    misc.options options, (err, options) ->
      return finish err if err
      uploaded = 0
      each( options )
      .on 'item', (options, next) ->
        conditions.all options, next, ->
          # Start real work
          if options.binary
            return options.ssh.sftp (err, sftp) ->
              from = fs.createReadStream options.source#, encoding: 'binary'
              to = sftp.createWriteStream options.destination#, encoding: 'binary'
              l = 0
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
        finish err, uploaded
    result
  ###

  `write(options, callback)`
  --------------------------

  Write a file or a portion of an existing file.

  `options`           Command options include:   

  *   `from`          Replace from after this marker, a string or a regular expression.   
  *   `local_source`  Treat the source as local instead of remote, only apply with "ssh" option.   
  *   `to`            Replace to before this marker, a string or a regular expression.   
  *   `match`         Replace this marker, a string or a regular expression.   
  *   `replace`       The content to be inserted, used conjointly with the from, to or match options.   
  *   `content`       Text to be written, an alternative to source which reference a file.   
  *   `source`        File path from where to extract the content, do not use conjointly with content.   
  *   `destination`   File path where to write content to.   
  *   `backup`        Create a backup, append a provided string to the filename extension or a timestamp if value is not a string.   
  *   `append`        Append the content to the destination file. If destination does not exist, the file will be created.   
  *   `write`         An array containing multiple transformation where a transformation is an object accepting the options `from`, `to`, `match` and `replace`
  *   `ssh`           Run the action on a remote server using SSH, an ssh2 instance or an configuration object used to initialize the SSH connection.   

  `callback`          Received parameters are:   

  *   `err`           Error object if any.   
  *   `rendered`      Number of rendered files.   
  
  The option "append" allows some advance usages. If "append" is 
  null, it will add the `replace` value at the end of the file 
  if no match if found and if the value is a string. When used 
  conjointly with the `match` and `replace` options, it gets even 
  more interesting. If append is a string or a regular expression, 
  it will place the "replace" string just after the match. An 
  append string will be converted to a regular expression such as 
  "test" will end up converted as the string "test" is similar to the 
  RegExp /^.*test.*$/mg.

  Example replacing part of a file using from and to markers

      mecano.write
        content: 'here we are\n# from\nlets try to replace that one\n# to\nyou coquin'
        from: '# from\n'
        to: '# to'
        replace: 'my friend\n'
        destination: "#{scratch}/a_file"
      , (err, written) ->
        # here we are\n# from\nmy friend\n# to\nyou coquin
  
  Example replacing a matched line by a string with

      mecano.write
        content: 'email=david(at)adaltas(dot)com\nusername=root'
        match: /(username)=(.*)/
        replace: '$1=david (was $2)'
        destination: "#{scratch}/a_file"
      , (err, written) ->
        # email=david(at)adaltas(dot)com\nusername=david (was root)
  
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
        '# A config file\n#property=30\nproperty=50\n#End of Config'

  Example appending a line after each line containing "property"

      mecano.write
        content: '#A config file\n#property=30\nproperty=10\n#End of Config'
        match: /^.*comment.*$/mg
        replace: '# comment'
        destination: "#{scratch}/replace"
        append: 'property'
      , (err, written) ->
        '# A config file\n#property=30\n# comment\nproperty=50\n# comment\n#End of Config'

  Example with multiple transformations

      mecano.write
        content: 'username: me\nemail: my@email\nfriends: you'
        write: [
          match: /^(username).*$/mg
          replace: "$1: you"
        ,
          match: /^email.*$/mg
          replace: ""
        ,
          match: /^(friends).*$/mg
          replace: "$1: me"
        ]
        destination: "#{scratch}/file"
      , (err, written) ->
        # username: you\n\nfriends: me

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
        # Validate parameters
        return next new Error 'Missing source or content' unless (options.source or options.content?) or options.replace or options.write?.length
        return next new Error 'Define either source or content' if options.source and options.content
        return next new Error 'Missing destination' unless options.destination
        destination  = null
        destinationHash = null
        content = null
        #fullContent = null
        from = to = between = null
        append = options.append
        write = options.write
        write ?= []
        if options.from? or options.to? or options.match?
          write.push
            from: options.from
            to: options.to
            match: options.match
            replace: options.replace
            append: options.append
          # append = false
        # Start real work
        readSource = ->
          if options.content?
            content = options.content
            return readDestination()
          # Option "local_source" force to bypass the ssh 
          # connection, use by the upload function
          source = options.source or options.destination
          ssh = if options.local_source then null else options.ssh
          misc.file.exists ssh, source, (err, exists) ->
            return next err if err
            unless exists
              return next new Error "Source does not exist: \"#{options.source}\"" if options.source
              content = ''
              return readDestination()
            misc.file.readFile ssh, source, 'utf8', (err, src) ->
              return next err if err
              content = src
              readDestination()
        readDestination = ->
          # no need to test changes if destination is a callback
          return render() if typeof options.destination is 'function'
          exists = ->
            misc.file.exists options.ssh, options.destination, (err, exists) ->
              return next err if err
              if exists then read() else mkdir()
          mkdir = ->
            mecano.mkdir 
              ssh: options.ssh
              destination: path.dirname(options.destination)
              uid: options.uid
              gid: options.gid
              mode: options.mode
            , (err, created) ->
              return next err if err
              render()
          read = ->
            misc.file.readFile options.ssh, options.destination, 'utf8', (err, dest) ->
              return next err if err
              destinationHash = misc.string.hash dest
              render()
          exists()
        render = ->
          return replacePartial() unless options.context?
          try
            content = eco.render content.toString(), options.context
          catch err
            err = new Error err if typeof err is 'string'
            return next err
          replacePartial()
        replacePartial = ->
          # return writeContent() unless fullContent?
          return writeContent() unless write.length
          for opts in write
            if opts.match
              if opts.match instanceof RegExp
                if opts.match.test content
                  content = content.replace opts.match, opts.replace
                  append = false
                else if opts.append and typeof opts.replace is 'string'
                  if typeof opts.append is "string"
                    opts.append = new RegExp "^.*#{opts.append}.*$", 'mg'
                  if opts.append instanceof RegExp
                    posoffset = 0
                    orgContent = content
                    while (res = opts.append.exec orgContent) isnt null
                      pos = posoffset + res.index + res[0].length
                      content = content.slice(0,pos) + '\n'+opts.replace + content.slice(pos)
                      posoffset += opts.replace.length + 1
                      break unless opts.append.global
                    append = false
                  else
                    linebreak = if content.length is 0 or content.substr(content.length - 1) is '\n' then '' else '\n'
                    content = content + linebreak + opts.replace
                    append = false
                else
                  # Did not match, try next one
                  continue
              else
                from = content.indexOf(opts.match)
                to = from + opts.match.length
                content = content.substr(0, from) + opts.replace + content.substr(to)
            else
              from = if opts.from then content.indexOf(opts.from) + opts.from.length else 0
              to = if opts.to then content.indexOf(opts.to) else content.length
              content = content.substr(0, from) + opts.replace + content.substr(to)
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


