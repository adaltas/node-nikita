
fs = require 'fs'
path = require 'path'
each = require 'each'
util = require 'util'
Stream = require 'stream'
exec = require 'ssh2-exec'
ini = require 'ini'
tilde = require 'tilde-expansion'
file = require './file'
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
      .call (location, next) ->
        misc.path.normalize location, (location) ->
          normalized.push location
          next()
      .then ->
        callback path.resolve normalized...
  mode:
    stringify: (mode) ->
      if typeof mode is 'number' then mode.toString(8) else mode
    compare: (modes...) ->
      ref = misc.mode.stringify modes[0]
      for i in [1...modes.length]
        mode = misc.mode.stringify modes[i]
        l = Math.min ref.length, mode.length
        return false if mode.substr(-l) isnt ref.substr(-l)
      true
  file: require './file'
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
        if v and typeof v is 'object' and typeof new_obj[k] isnt 'undefined'
          new_obj[k] = misc.yaml.merge v, new_obj[k], undefinedOnly
          continue
        new_obj[k] = v if typeof new_obj[k] is 'undefined'
      new_obj
    clean: (original, new_obj, undefinedOnly) ->
      for k, v of original
        if v and typeof v is 'object' and new_obj[k]
          original[k] = misc.yaml.clean v, new_obj[k], undefinedOnly
          continue
        delete original[k] if new_obj[k]  is null
      original
  ini:
    clean: (content, undefinedOnly) ->
      for k, v of content
        if v and typeof v is 'object'
          content[k] = misc.ini.clean v, undefinedOnly
          continue
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
    # same as ini parse bu transforme value which are true an type of true as ''
    # to be user by stringify_single_key
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
    # works like stringy but write only the key when the value is ''
    # be careful when using ini.parse is parses singke key line as key = true
    stringify_single_key: (obj, section, options={}) ->
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
                out += if val is '' or val is true then "#{k}" + "\n" else safe("#{k}[]") + options.separator + safe(item) + "\n"
        else if val and typeof val is "object"
          children.push k
        else
          out += if val is '' or val is true then "#{k}" + eol else safe(k) + options.separator + safe(val) + eol
      if section and out.length
        out = "[" + safe(section) + "]" + eol + out
      children.forEach (k, _, __) ->
        nk = dotSplit(k).join '\\.'
        child = misc.ini.stringify_single_key(obj[k], (if section then section + "." else "") + nk, options)
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
  cgconfig:
    parse: (str) ->
      lines = string.lines str
      list_of_mount_sections = []
      list_of_group_sections = {}
      # variable which hold the cursor position
      current_mount = false
      current_group = false
      current_group_name = ''
      current_group_controller = false
      current_group_perm = false
      current_group_perm_content = false
      current_default = false
      # variables which hold the data
      current_mount_section = null
      current_group_section = null # group section is a tree but only of group
      current_controller_name = null
      current_group_section_perm_name = null
      lines.forEach (line, _, __) ->
        return if not line or line.match(/^\s*$/)
        if !current_mount and !current_group and !current_default
          if /^mount\s{$/.test line # start of a mount object
            current_mount = true
            current_mount_section = []
          if /^(group)\s([A-z|0-9|\/]*)\s{$/.test line # start of a group object
            current_group = true
            match = /^(group)\s([A-z|0-9|\/]*)\s{$/.exec line
            current_group_name = match[2]
            current_group_section = {}
            list_of_group_sections["#{current_group_name}"] ?= {}
          if /^(default)\s{$/.test line # start of a special group object named default
            current_group = true
            current_group_name = ''
            current_group_section = {}
            list_of_group_sections["#{current_group_name}"] ?= {}
        else
          # we are parsing a mount object
          # ^(cpuset|cpu|cpuacct|memory|devices|freezer|net_cls|blkio)\s=\s[aA-zZ|\s]*
          if current_mount
            if /^}$/.test line # close the mount object
              list_of_mount_sections.push current_mount_section...
              current_mount = false
              current_mount_section = []
            # add the line to mont object
            else
              line = line.replace ';',''
              sep = '='
              sep = ':' if line.indexOf(':') isnt -1
              line = line.split sep
              current_mount_section.push type: "#{line[0].trim()}", path:"#{line[1].trim()}"
          # we are parsing a group object
          # ^(cpuset|cpu|cpuacct|memory|devices|freezer|net_cls|blkio)\s=\s[aA-zZ|\s]*
          if current_group
            # if a closing bracket is encountered, it should set the cursor to false
            if /^(\s*)?}$/.test line
              if current_group
                if current_group_controller
                  current_group_controller = false
                else if current_group_perm
                  if current_group_perm_content
                    current_group_perm_content = false
                  else
                    current_group_perm = false
                else 
                  current_group = false
                  # push the group if the closing bracket is closing a group
                  # list_of_group_sections["#{current_group_name}"] = current_group_section
                  current_group_section = null
              #closing the group object
            else
              match = /^\s*(cpuset|cpu|cpuacct|memory|devices|freezer|net_cls|blkio)\s{$/.exec line
              # currently reading a group config
              if !current_group_perm and !current_group_controller
                #if neither working in perm or controller section, we are declaring one of them
                if /^\s*perm\s{$/.test line # perm declaration
                  current_group_perm =  true
                  current_group_section['perm'] = {}
                  list_of_group_sections["#{current_group_name}"]['perm'] = {}
                if match #controller declaration
                  current_group_controller =  true
                  current_controller_name = match[1]
                  current_group_section["#{current_controller_name}"] = {}
                  list_of_group_sections["#{current_group_name}"]["#{current_controller_name}"] ?= {}
              else if current_group_perm and current_group_perm_content# perm config
                line = line.replace ';',''
                line = line.split('=')
                [type,value] = line
                current_group_section['perm'][current_group_section_perm_name][type.trim()] = value.trim()
                list_of_group_sections["#{current_group_name}"]['perm'][current_group_section_perm_name][type.trim()] = value.trim()
              else if current_group_controller # controller config
                line = line.replace ';',''
                sep = '='
                sep = ':' if line.indexOf(':') isnt -1
                line = line.split sep
                [type, value] = line
                list_of_group_sections["#{current_group_name}"]["#{current_controller_name}"][type.trim()] ?= value.trim()
              else
                match_admin = /^\s*(admin|task)\s{$/.exec line
                if match_admin # admin or task declaration
                  [_,name] = match_admin #the name is either admin or task
                  current_group_perm_content = true
                  current_group_section_perm_name = name
                  current_group_section['perm'][name] = {}
                  list_of_group_sections["#{current_group_name}"]['perm'][name] =  {}
      mounts: list_of_mount_sections, groups: list_of_group_sections
    stringify: (obj, options={}) ->
      obj.mounts ?= []
      obj.groups ?= {}
      render = ""
      options.indent ?= 2
      indent = ''
      indent += ' ' for i in [1..options.indent]
      sections = []
      if obj.mounts.length isnt 0
        mount_render = "mount {\n"
        for mount,k in obj.mounts
          mount_render += "#{indent}#{mount.type} = #{mount.path};\n"
        mount_render += '}'
        sections.push mount_render
      count = 0
      for name, group of obj.groups
        group_render = if (name is '') or (name is 'default') then 'default {\n' else "group #{name} {\n"
        for key, value of group
          if key is 'perm'
            group_render += "#{indent}perm {\n"
            if value['admin']?
              group_render += "#{indent}#{indent}admin {\n"
              group_render += "#{indent}#{indent}#{indent}#{prop} = #{val};\n" for prop, val of value['admin']
              group_render += "#{indent}#{indent}}\n"
            if value['task']?
              group_render += "#{indent}#{indent}task {\n"
              group_render += "#{indent}#{indent}#{indent}#{prop} = #{val};\n" for prop, val of value['task']
              group_render += "#{indent}#{indent}}\n"
            group_render += "#{indent}}\n"
          else
            group_render += "#{indent}#{key} {\n"
            group_render += "#{indent}#{indent}#{prop} = #{val};\n" for prop, val of value
            group_render += "#{indent}}\n"
        group_render += '}'
        count++
        sections.push group_render
      sections.join "\n"
  # parse the content of tmpfs daemon configuration file
  tmpfs:
    parse: (str) ->
      lines = string.lines str
      files = {}
      lines.forEach (line, _, __) ->
        return if not line or line.match(/^#.*$/)
        values = [type,mount,mode,uid,gid,age,argu] = line.split(/\s+/)
        obj = {}
        for i,key of ['type','mount','perm','uid','gid','age','argu']
          obj[key] = if values[i] isnt undefined then values[i] else '-'
          if i is "#{values.length-1}"
            files[mount] = obj if obj['mount']?
      files
    stringify: (obj) ->
      lines = []
      for k, v of obj
        for i,key of ['mount','perm','uid','gid','age','argu']
          v[key] = if v[key] isnt undefined then v[key] else '-'
        lines.push "#{v.type} #{v.mount} #{v.perm} #{v.uid} #{v.gid} #{v.age} #{v.argu}"
      lines.join '\n'
