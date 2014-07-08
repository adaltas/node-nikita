
crypto = require 'crypto'
fs = require 'fs'
path = require 'path'
each = require 'each'
util = require 'util'
Stream = require 'stream'
exec = require 'ssh2-exec'
connect = require 'ssh2-connect'
buffer = require 'buffer'
rimraf = require 'rimraf'
ini = require 'ini'
tilde = require 'tilde-expansion'
ssh2fs = require 'ssh2-fs'

misc = module.exports = 
  array:
    intersect: (array) ->
      return [] if array is null
      result = []
      for item, i in array
        continue if result.indexOf(item) isnt -1
        for argument, j in arguments
          break if argument.indexOf(item) is -1
        result.push item if j is arguments.length
      result
  regexp:
    escape: (str) ->
      str.replace /[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&"
  object:
    equals: (obj1, obj2, keys) ->
      keys1 = Object.keys obj1
      keys2 = Object.keys obj2
      if keys
        keys1 = keys1.filter (k) -> keys.indexOf(k) isnt -1
        keys2 = keys2.filter (k) -> keys.indexOf(k) isnt -1
      else keys = keys1
      return false if keys1.length isnt keys2.length
      for k in keys
        return false if obj1[k] isnt obj2[k]
      return true
  path:
    normalize: (location, callback) ->
      tilde location, (location) ->
        callback path.normalize location
    resolve: (locations..., callback) ->
      normalized = []
      each(locations)
      .on 'item', (location, next) ->
        misc.path.normalize location, (location) ->
          normalized.push location
          next()
      .on 'end', ->
        callback path.resolve normalized...
  mode:
    stringify: (mode) ->
      if typeof mode is 'number' then mode.toString(8) else mode
    compare: (modes...) ->
      # ref = modes[0]
      # ref = ref.toString(8) if typeof ref is 'number'
      ref = misc.mode.stringify modes[0]
      for i in [1...modes.length]
        mode = misc.mode.stringify modes[i]
        # mode = modes[i]
        # mode = mode.toString(8) if typeof mode is 'number'
        l = Math.min ref.length, mode.length
        return false if mode.substr(-l) isnt ref.substr(-l)
      true
  file:
    copyFile: (ssh, source, destination, callback) ->
      s = (ssh, callback) ->
        unless ssh
        then callback null, fs
        else ssh.sftp callback
      s ssh, (err, fs) ->
        rs = fs.createReadStream source
        ws = rs.pipe fs.createWriteStream destination
        ws.on 'close', ->
          fs.end() if fs.end
          modified = true
          callback()
        ws.on 'error', callback
    ###
    Compare modes
    -------------
    ###
    cmpmod: (modes...) ->
      console.log 'Deprecated'
      misc.mode.compare.call @, modes...
    copy: (ssh, source, destination, callback) ->
      unless ssh
        source = fs.createReadStream(u.pathname)
        source.pipe destination
        destination.on 'close', callback
        destination.on 'error', callback
      else
        # todo: use cp to copy over ssh
        callback new Error 'Copy over SSH not yet implemented'
    ###
    `files.hash(file, [algorithm], callback)`
    -----------------------------------------
    Retrieve the hash of a supplied file in hexadecimal 
    form. If the provided file is a directory, the returned hash 
    is the sum of all the hashs of the files it recursively 
    contains. The default algorithm to compute the hash is md5.

    Throw an error if file does not exist unless it is a directory.

        misc.file.hash ssh, '/path/to/file', (err, md5) ->
          md5.should.eql '287621a8df3c3f6c99c7b7645bd09ffd'

    ###
    hash: (ssh, file, algorithm, callback) ->
      if arguments.length is 3
        callback = algorithm
        algorithm = 'md5'
      hasher = (ssh, path, callback) ->
        shasum = crypto.createHash algorithm
        ssh2fs.createReadStream ssh, path, (err, stream) ->
          return callback err if err
          stream
          .on 'data', (data) ->
            shasum.update data
          .on 'error', (err) ->
            return callback() if err.code is 'EISDIR'
            callback err
          .on 'end', ->
            callback err, shasum.digest 'hex'
      hashs = []
      ssh2fs.stat ssh, file, (err, stat) ->
        return callback new Error "Does not exist: #{file}" if err?.code is 'ENOENT'
        return callback err if err
        file += '/**' if stat.isDirectory()
        # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        # This is not working over ssh, we
        # need to implement the "glob" module
        # over ssh
        # |||||||||||||||||||||||||||||||||
        # Temp fix, we support file md5 over
        # ssh, but not directory:
        if ssh and stat.isFile()
          return hasher ssh, file, callback
        each()
        .files(file)
        .on 'item', (item, next) ->
          hasher ssh, item, (err, h) ->
            return next err if err
            hashs.push h if h?
            next()
        .on 'error', (err) ->
          callback err
        .on 'end', ->
          switch hashs.length
            when 0
              if stat.isFile() 
              then callback new Error "Does not exist: #{file}"
              else callback null, crypto.createHash(algorithm).update('').digest('hex')
            when 1
              return callback null, hashs[0]
            else
              hashs = crypto.createHash(algorithm).update(hashs.join('')).digest('hex')
              return callback null, hashs
    ###
    `files.compare(files, callback)`
    --------------------------------
    Compare the hash of multiple file. Return the file md5 
    if the file are the same or false otherwise.
    ###
    compare: (ssh, files, callback) ->
      return callback new Error 'Minimum of 2 files' if files.length < 2
      result = null
      each(files)
      .parallel(true)
      .on 'item', (file, next) ->
        misc.file.hash ssh, file, (err, md5) ->
          return next err if err
          if result is null
            result = md5 
          else if result isnt md5
            result = false 
          next()
      .on 'error', (err) ->
        callback err
      .on 'end', ->
        callback null, result
    ###
    remove(ssh, path, callback)
    ---------------------------
    Remove a file or directory
    ###
    remove: (ssh, path, callback) ->
      unless ssh
        rimraf path, callback
      else
        # Not very pretty but fast and no time to try make a version of rimraf over ssh
        child = exec ssh, "rm -rdf #{path}"
        child.on 'exit', (code) ->
          callback null, code
  string:
    escapeshellarg: (arg) ->
      result = arg.replace /[^\\]'/g, (match) ->
        match.slice(0, 1) + '\\\''
      "'#{result}'"
    ###
    `string.hash(file, [algorithm], callback)`
    ------------------------------------------
    Output the hash of a supplied string in hexadecimal 
    form. The default algorithm to compute the hash is md5.
    ###
    hash: (data, algorithm) ->
      if arguments.length is 1
        algorithm = 'md5'
      crypto.createHash(algorithm).update(data).digest('hex')
    repeat: (str, l) ->
      Array(l+1).join str
    ###
    `string.endsWith(search, [position])`
    -------------------------------------
    Determines whether a string ends with the characters of another string, 
    returning true or false as appropriate.   
    This method has been added to the ECMAScript 6 specification and its code 
    was borrowed from [Mozilla](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/endsWith)
    ###
    endsWith: (str, search, position) ->
      position = position or str.length
      position = position - search.length
      lastIndex = str.lastIndexOf search
      return lastIndex isnt -1 and lastIndex is position
  ssh:
    ###
    passwd(ssh, [user], callback)
    ----------------------
    Return information present in '/etc/passwd' and cache the 
    result in the provided ssh instance as "passwd".

    Result look like: 
        { root: {
            uid: '0',
            gid: '0',
            comment: 'root',
            home: '/root',
            shell: '/bin/bash' }, ... }
    ###
    passwd: (ssh, username, callback) ->
      if arguments.length is 3
        # Username may be null, stop here
        return callback null, null unless username
        # Is user present in cache
        if ssh.passwd and ssh.passwd[username]
          return callback null, ssh.passwd[username]
        # Reload the cache and check if user is here
        ssh.passwd = null
        return misc.ssh.passwd ssh, (err, users) ->
          return callback err if err
          user = users[username]
          # Dont throw exception, just return undefined
          # return callback new Error "User #{username} does not exists" unless user
          callback null, user
      callback = username
      username = null
      # Grab passwd from the cache
      return callback null, ssh.passwd if ssh.passwd
      # Alternative is to use the id command, eg `id -u ubuntu`
      ssh2fs.readFile ssh, '/etc/passwd', 'ascii', (err, lines) ->
        return callback err if err
        passwd = []
        for line in lines.split '\n'
          info = /(.*)\:\w\:(.*)\:(.*)\:(.*)\:(.*)\:(.*)/.exec line
          continue unless info
          passwd[info[1]] = uid: parseInt(info[2]), gid: parseInt(info[3]), comment: info[4], home: info[5], shell: info[6]
        ssh.passwd = passwd
        callback null, passwd
    ###
    group(ssh, [group], callback)
    ----------------------
    Return information present in '/etc/group' and cache the 
    result in the provided ssh instance as "group".

    Result look like: 
        { root: {
            password: 'x'
            gid: 0,
            user_list: [] },
          bin: {
            password: 'x',
            gid: 1,
            user_list: ['bin','daemon'] } }
    ###
    group: (ssh, group, callback) ->
      if arguments.length is 3
        # Group may be null, stop here
        return callback null, null unless group
        # Is group present in cache
        if ssh.cache_group and ssh.cache_group[group]
          return callback null, ssh.cache_group[group]
        # Reload the cache and check if user is here
        ssh.cache_group = null
        return misc.ssh.group ssh, (err, groups) ->
          return err if err
          gid = groups[group]
          # Dont throw exception, just return undefined
          # return callback new Error "Group does not exists: #{group}" unless gid
          callback null, gid
      callback = group
      group = null
      # Grab group from the cache
      return callback null, ssh.cache_group if ssh.cache_group
      # Alternative is to use the id command, eg `id -g admin`
      ssh2fs.readFile ssh, '/etc/group', 'ascii', (err, lines) ->
        return callback err if err
        group = []
        for line in lines.split '\n'
          info = /(.*)\:(.*)\:(.*)\:(.*)/.exec line
          continue unless info
          group[info[1]] = password: info[2], gid: parseInt(info[3]), user_list: if info[4] then info[4].split ',' else []
        ssh.cache_group = group
        callback null, group
  ###
  `pidfileStatus(ssh, pidfile, [options], callback)`
  ---------------------------------------

  Return a status code after reading a status file. Any existing 
  pidfile referencing a dead process will be removed.

  The callback is called with an error and a status code. Values 
  expected as status code are:

  *   0 if pidfile math a running process
  *   1 if pidfile does not exists
  *   2 if pidfile exists but match no process
  ###
  pidfileStatus: (ssh, pidfile, options, callback) ->
    if arguments.length is 3
      callback = options
      options = {}
    ssh2fs.readFile ssh, pidfile, 'ascii', (err, pid) ->
      # pidfile does not exists
      return callback null, 1 if err and err.code is 'ENOENT'
      return callback err if err
      stdout = []
      run = exec
        cmd: "ps aux | grep #{pid.trim()} | grep -v grep | awk '{print $2}'"
        ssh: ssh
      run.stdout.on 'data', (data) ->
        stdout.push data
      if options.stdout
        run.stdout.pipe options.stdout
      if options.stderr
        run.stderr.pipe options.stderr
      run.on "exit", (code) ->
        stdout = stdout.join('')
        # pidfile math a running process
        return callback null, 0 unless stdout is ''
        misc.file.remove ssh, pidfile, (err, removed) ->
          return callback err if err
          # pidfile exists but match no process
          callback null, 2
  ###
  `isPortOpen(port, host, callback)`: Check if a port is already open

  ###
  isPortOpen: (port, host, callback) ->
    if arguments.length is 2
      callback = host
      host = '127.0.0.1'
    exec "nc #{host} #{port} < /dev/null", (err, stdout, stderr) ->
      return callback null, true unless err
      return callback null, false if err.code is 1
      callback err
  ###
  `merge([inverse], obj1, obj2, ...]`: Recursively merge objects
  --------------------------------------------------------------
  On matching keys, the last object take precedence over previous ones 
  unless the inverse arguments is provided as true. Only objects are 
  merge, arrays are overwritten.

  Enrich an existing object with a second one:
    obj1 = { a_key: 'a value', b_key: 'b value'}
    obj2 = { b_key: 'new b value'}
    result = misc.merge obj1, obj2
    assert.eql result, obj1
    assert.eql obj1.b_key, 'new b value'

  Create a new object from two objects:
    obj1 = { a_key: 'a value', b_key: 'b value'}
    obj2 = { b_key: 'new b value'}
    result = misc.merge {}, obj1, obj2
    assert.eql result.b_key, 'new b value'

  Using inverse:
    obj1 = { b_key: 'b value'}
    obj2 = { a_key: 'a value', b_key: 'new b value'}
    misc.merge true, obj1, obj2
    assert.eql obj1.a_key, 'a value'
    assert.eql obj1.b_key, 'b value'

  ###
  merge: () ->
    target = arguments[0]
    from = 1
    to = arguments.length
    if typeof target is 'boolean'
      inverse = !! target
      target = arguments[1]
      from = 2
    # Handle case when target is a string or something (possible in deep copy)
    if typeof target isnt "object" and typeof target isnt 'function'
      target = {}
    for i in [from ... to]
      # Only deal with non-null/undefined values
      if (options = arguments[ i ]) isnt null
        # Extend the base object
        for name of options 
          src = target[ name ]
          copy = options[ name ]
          # Prevent never-ending loop
          continue if target is copy
          # Recurse if we're merging plain objects
          if copy? and typeof copy is 'object' and not Array.isArray(copy) and copy not instanceof RegExp
            clone = src and ( if src and typeof src is 'object' then src else {} )
            # Never move original objects, clone them
            target[ name ] = misc.merge false, clone, copy
          # Don't bring in undefined values
          else if copy isnt undefined
            target[ name ] = copy unless inverse and typeof target[ name ] isnt 'undefined'
    # Return the modified object
    target
  kadmin: (options, cmd) ->
    realm = if options.realm then "-r #{options.realm}" else ''
    if options.kadmin_principal
    then "kadmin #{realm} -p #{options.kadmin_principal} -s #{options.kadmin_server} -w #{options.kadmin_password} -q '#{cmd}'"
    else "kadmin.local #{realm} -q '#{cmd}'"
  ini:
    safe: (val) ->
      if ( typeof val isnt "string" or val.match(/[\r\n]/) or val.match(/^\[/) or (val.length > 1 and val.charAt(0) is "\"" and val.slice(-1) is "\"") or val isnt val.trim() )
      then JSON.stringify(val)
      else val.replace(/;/g, '\\;')

    dotSplit: `function (str) {
      return str.replace(/\1/g, '\2LITERAL\\1LITERAL\2')
             .replace(/\\\./g, '\1')
             .split(/\./).map(function (part) {
               return part.replace(/\1/g, '\\.')
                      .replace(/\2LITERAL\\1LITERAL\2/g, '\1')
             })
    }`
    parse: (content, options) ->
      ini.parse content
    ###
    
    Each category is surrounded by one or several square brackets. The number of brackets indicates
    the depth of the category.
    Options are   

    *   `comment`   Default to ";"

    ###
    parse_multi_brackets: (str, options={}) ->
      lines = str.split /[\r\n]+/g
      current = data = {}
      stack = [current]
      comment = options.comment or ';'
      lines.forEach (line, _, __) ->
        return if not line or line.match(/^\s*$/)
        # Category
        if match = line.match /^\s*(\[+)(.+?)(\]+)\s*$/
          depth = match[1].length
          # Add a child
          if depth is stack.length
            parent = stack[depth - 1]
            parent[match[2]] = current = {}
            stack.push current
          # Invalid child hierarchy
          if depth > stack.length
            throw new Error "Invalid child #{match[2]}"
          # Move up or at the same level
          if depth < stack.length
            stack.splice depth, stack.length - depth
            parent = stack[depth - 1]
            parent[match[2]] = current = {}
            stack.push current
        # comment
        else if comment and match = line.match ///^\s*(#{comment}.*)$///
          current[match[1]] = null
        # key value
        else if match = line.match /^\s*(.+?)\s*=\s*(.+)\s*$/
          current[match[1]] = match[2]
        # else
        else if match = line.match /^\s*(.+?)\s*$/
          current[match[1]] = null
      data
    stringify: (obj, section, options) ->
      if arguments.length is 2
        options = section
        section = undefined
      options.separator ?= ' = '
      eol = if process.platform is "win32" then "\r\n" else "\n"
      safe = misc.ini.safe
      dotSplit = misc.ini.dotSplit
      children = []
      out = ""
      Object.keys(obj).forEach (k, _, __) ->
        val = obj[k]
        if val and Array.isArray val
            val.forEach (item) ->
                out += safe("#{k}[]") + options.separator + safe(item) + "\n"
        else if val and typeof val is "object"
          children.push k
        else
          out += safe(k) + options.separator + safe(val) + eol
      if section and out.length
        out = "[" + safe(section) + "]" + eol + out
      children.forEach (k, _, __) ->
        nk = dotSplit(k).join '\\.'
        child = misc.ini.stringify(obj[k], (if section then section + "." else "") + nk, options)
        if out.length and child.length
          out += eol
        out += child
      out
    stringify_square_then_curly: (content, depth=0, options={}) ->
      if arguments.length is 2
        options = depth
        depth = 0
      options.separator ?= ' = '
      out = ''
      indent = ' '
      prefix = ''
      for i in [0...depth]
        prefix += indent
      for k, v of content
        # isUndefined = typeof v is 'undefined'
        isBoolean = typeof v is 'boolean'
        isNull = v is null
        isArray = Array.isArray v
        isObj = typeof v is 'object' and not isNull and not isArray
        if isObj
          if depth is 0
            out += "#{prefix}[#{k}]\n"
            out += misc.ini.stringify_square_then_curly v, depth + 1, options
            out += "\n"
          else
            out += "#{prefix}#{k}#{options.separator}{\n"
            out += misc.ini.stringify_square_then_curly v, depth + 1, options
            out += "#{prefix}}\n"
        else 
          if isArray
            outa = []
            for element in v
              outa.push "#{prefix}#{k}#{options.separator}#{element}"
            out += outa.join '\n'
          else if isNull
            out += "#{prefix}#{k}#{options.separator}null"
          else if isBoolean
            out += "#{prefix}#{k}#{options.separator}#{if v then 'true' else 'false'}"
          else
            out += "#{prefix}#{k}#{options.separator}#{v}"
          out += '\n'
      out
    ###
    Each category is surrounded by one or several square brackets. The number of brackets indicates
    the depth of the category.
    ###
    stringify_multi_brackets: (content, depth=0, options={}) ->
      if arguments.length is 2
        options = depth
        depth = 0
      options.separator ?= ' = '
      out = ''
      indent = '  '
      prefix = ''
      for i in [0...depth]
        prefix += indent
      for k, v of content
        # isUndefined = typeof v is 'undefined'
        isBoolean = typeof v is 'boolean'
        isNull = v is null
        isObj = typeof v is 'object' and not isNull
        continue if isObj
        if isNull
          out += "#{prefix}#{k}"
        else if isBoolean
          out += "#{prefix}#{k}#{options.separator}#{if v then 'true' else 'false'}"
        else
          out += "#{prefix}#{k}#{options.separator}#{v}"
        out += '\n'
      for k, v of content
        isNull = v is null
        isObj = typeof v is 'object' and not isNull
        continue unless isObj
        out += "#{prefix}#{misc.string.repeat '[', depth+1}#{k}#{misc.string.repeat ']', depth+1}\n"
        out += misc.ini.stringify_multi_brackets v, depth + 1, options
      out
  args: (args, overwrite_goptions={}) ->
    # [goptions, options, callback] = args
    if args.length is 2 and typeof args[1] is 'function'
      args[2] = args[1]
      args[1] = args[0]
      args[0] = null
    else if args.length is 1
      args[1] = args[0]
      args[0] = null
    args[0] ?= misc.merge parallel: true, overwrite_goptions
    args
  ###

  `options(options, callback)`
  ----------------------------
  Normalize options. An ssh connection is needed if the key "ssh" 
  hold a configuration object. The 'uid' and 'gid' fields will 
  be converted to integer if they match a username or a group.   

  `callback`          Received parameters are:   

  *   `err`           Error object if any.   
  *   `options`       Sanitized options.   

  ###
  options: (options, callback) ->
    options = [options] unless Array.isArray options
    each(options)
    .on 'item', (options, next) ->
      options.if = [options.if] if options.if? and not Array.isArray options.if
      # options.if_exists = options.destination if options.if_exists is true and options.destination
      options.if_exists = [options.if_exists] if options.if_exists? and not Array.isArray options.if_exists
      # options.not_if_exists = options.destination if options.not_if_exists is true and options.destination
      options.not_if_exists = [options.not_if_exists] if options.not_if_exists? and not Array.isArray options.not_if_exists
      if options.if_exists then for el, i in options.if_exists
        options.if_exists[i] = options.destination if el is true and options.destination
      if options.not_if_exists then for v, i in options.not_if_exists
        options.not_if_exists[i] = options.destination if v is true and options.destination
      options.mode ?= options.chmod if options.chmod
      connection = ->
        return source() unless options.ssh
        return source() if options.ssh._host
        connect options.ssh, (err, ssh) ->
          return next err if err
          options.ssh = ssh
          source()
      source = ->
        return destination() unless options.source?
        return destination() if /^\w+:/.test options.source # skip url
        tilde options.source, (source) ->
          options.source = source
          destination()
      destination = ->
        return mode() unless options.destination?
        return mode() unless typeof options.destination is 'string' # destination is a function
        return mode() if /^\w+:/.test options.source # skip url
        tilde options.destination, (destination) ->
          options.destination = destination
          mode()
      mode = ->
        options.mode = parseInt(options.mode, 8) if typeof options.mode is 'string'
        uid()
      uid = ->
        # uid=`id -u $USER`,
        return gid() unless options.uid
        return gid() if typeof options.uid is 'number' or /\d+/.test options.uid
        misc.ssh.passwd options.ssh, options.uid, (err, user) ->
          return next err if err
          if user
            options.uid = user.uid
            options.gid ?= user.gid
          gid()
      gid = ->
        # gid=`getent group $GROUP | cut -d: -f3`
        return next() unless options.gid
        return next() if typeof options.gid is 'number' or /\d+/.test options.gid
        misc.ssh.group options.ssh, options.gid, (err, group) ->
          return next err if err
          options.gid = group.gid if group
          next()
      connection()
    .on 'both', (err) ->
      callback err, options





