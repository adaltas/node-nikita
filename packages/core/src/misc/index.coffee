
fs = require 'fs'
path = require 'path'
each = require 'each'
{merge} = require 'mixme'
util = require 'util'
Stream = require 'stream'
exec = require 'ssh2-exec'
ini = require './ini'
string = require './string'
array = require './array'
docker = require './docker'
ssh = require './ssh'

misc = module.exports =
  docker: require './docker'
  stats: require './stats'
  ssh: require './ssh'
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
        keys = array.merge keys1, keys2, array.unique keys1
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
      merge {}, obj
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
    console.warn 'Function merge is deprecated, use mixme instead'
    target = arguments[0]
    from = 1
    to = arguments.length
    if typeof target is 'boolean'
      inverse = !! target
      target = arguments[1]
      from = 2
    target ?= {}
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
          if copy? and typeof copy is 'object' and not Array.isArray(copy) and copy not instanceof RegExp and not Buffer.isBuffer copy
            clone = src and ( if src and typeof src is 'object' then src else {} )
            # Never move original objects, clone them
            target[ name ] = misc.merge false, clone, copy
          # Don't bring in undefined values
          else if copy isnt undefined
            copy = copy.slice(0) if Array.isArray copy
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
  ini: ini
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
