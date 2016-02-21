
crypto = require 'crypto'
fs = require 'fs'
path = require 'path'
each = require 'each'
util = require 'util'
Stream = require 'stream'
exec = require 'ssh2-exec'
rimraf = require 'rimraf'
ini = require 'ini'
tilde = require 'tilde-expansion'
ssh2fs = require 'ssh2-fs'
glob = require './glob'
string = require './string'

misc = module.exports = 
  array:
    flatten: (arr, ret) ->
      ret ?= []
      for i in [0 ... arr.length]
        if Array.isArray arr[i]
          misc.array.flatten arr[i], ret
        else
          ret.push arr[i]
      ret
    intersect: (array) ->
      return [] if array is null
      result = []
      for item, i in array
        continue if result.indexOf(item) isnt -1
        for argument, j in arguments
          break if argument.indexOf(item) is -1
        result.push item if j is arguments.length
      result
    unique: (array) ->
      o = {}
      for el in array then o[el] = true
      Object.keys o
    merge: (arrays...) ->
      r = []
      for array in arrays
        for el in array
          r.push el
      r
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
    diff: (obj1, obj2, keys) ->
      unless keys
        keys1 = Object.keys obj1
        keys2 = Object.keys obj2
        keys = misc.array.merge keys1, keys2, misc.array.unique keys1

      diff = {}
      for k, v of obj1
        continue unless keys.indexOf(k) >= 0
        continue if obj2[k] is v
        diff[k] = []
        diff[k][0] = v 
      for k, v of obj2
        continue unless keys.indexOf(k) >= 0
        continue if obj1[k] is v
        diff[k] ?= []
        diff[k][1] = v
      diff
    clone: (obj) ->
      misc.merge {}, obj
  path:
    normalize: (location, callback) ->
      tilde location, (location) ->
        callback path.normalize location
    resolve: (locations..., callback) ->
      normalized = []
      each(locations)
      .run (location, next) ->
        misc.path.normalize location, (location) ->
          normalized.push location
          next()
      .then ->
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
        return callback err if err
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
      console.log 'Deprecated, use `misc.mode.compare`'
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
        if not ssh
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
        else
          ssh2fs.stat ssh, path, (err, stat) ->
            return callback err if err
            return callback() if stat.isDirectory()
            # return callback null, crypto.createHash(algorithm).update('').digest('hex') if stat.isDirectory()
            exec
              cmd: "openssl #{algorithm} #{path}"
              ssh: ssh
            , (err, stdout) ->
              callback err if err
              callback err, /.*\s([\w\d]+)$/.exec(stdout.trim())[1]
      hashs = []
      ssh2fs.stat ssh, file, (err, stat) ->
        if err?.code is 'ENOENT'
          err = Error "Does not exist: #{file}"
          err.code = 'ENOENT'
          return callback err
        return callback err if err
        if stat.isFile()
          return hasher ssh, file, callback
        else if stat.isDirectory()
          compute = (files) ->
            files.sort()
            each files
            .run (item, next) ->
              hasher ssh, item, (err, h) ->
                return next err if err
                hashs.push h if h?
                next()
            .then (err) ->
              return callback err if err
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
          glob ssh, "#{file}/**", (err, files) ->
            return callback err if err
            compute files
        else
          callback Error "File type not supported"
    ###
    `files.compare(files, callback)`
    --------------------------------
    Compare the hash of multiple file. Return the file md5 
    if the file are the same or false otherwise.
    ###
    compare: (ssh, files, callback) ->
      return callback new Error 'Minimum of 2 files' if files.length < 2
      result = null
      each files
      .run (file, next) ->
        misc.file.hash ssh, file, (err, md5) ->
          return next err if err
          if result is null
            result = md5 
          else if result isnt md5
            result = false 
          next()
      .then (err) ->
        return callback err if err
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
        child = exec ssh, "rm -rf #{path}"
        child.on 'exit', (code) ->
          callback null, code
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
  yaml:
    merge: (original, new_obj, undefinedOnly) ->
      for k, v of original
        if typeof v is 'object'
          new_obj[k] = misc.yaml.merge v, new_obj[k], undefinedOnly
          continue
        new_obj[k] = v if typeof new_obj[k] is 'undefined'
      new_obj
    clean: (original, new_obj, undefinedOnly) ->
      for k, v of original
        if v and typeof v is 'object'
          original[k] = misc.yaml.clean v, new_obj[k], undefinedOnly
          continue
        # console.log k,v
        delete original[k] if new_obj[k]  is null
      original

  ini:
    clean: (content, undefinedOnly) ->
      for k, v of content
        if v and typeof v is 'object'
          content[k] = misc.ini.clean v, undefinedOnly
          continue
        # console.log k,v
        delete content[k] if typeof v is 'undefined'
        delete content[k] if not undefinedOnly and v is null
      content
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
      lines = string.lines str
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
    ###
    
    Same as the parse_multi_brackets instead it takes in count values which are defined on several lines
    As an example the ambari-agent .ini configuration file

    *   `comment`   Default to ";"

    ###
    parse_multi_brackets_multi_lines: (str, options={}) ->
      lines = string.lines str
      current = data = {}
      stack = [current]
      comment = options.comment or ';'
      writing = false
      previous = {}

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
          writing = false
          current[match[1]] = null
        # key value
        else if match = line.match /^\s*(.+?)\s*=\s*(.+)\s*$/
          writing = false
          current[match[1]] = match[2]
          previous = match[1]
          writing = true
        # else
        else if match = line.match /^\s*(.+?)\s*$/ 
          if writing
            current[previous] += match[1]
          else
            current[match[1]] = null
      data
    stringify: (obj, section, options={}) ->
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
    Taking now indent option into consideration: some file are indent aware ambari-agent .ini file
    ###
    stringify_multi_brackets: (content, depth=0, options={}) ->
      if arguments.length is 2
        options = depth
        depth = 0
      options.separator ?= ' = '
      out = ''
      indent = if options.indent? then options.indent else '  ' 
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
        out += "#{prefix}#{string.repeat '[', depth+1}#{k}#{string.repeat ']', depth+1}\n"
        out += misc.ini.stringify_multi_brackets v, depth + 1, options
      out
