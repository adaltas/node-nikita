
# `nikita.system.etc_group.read(options, [callback])`

Read and parse the group definition file located in "/etc/group".

## Options

* `cache` (boolean)   
  Cache the result inside the store.
* `target` (string)   
  Path to the group definition file, default to "/etc/group".
* `gid` (string|integer)   
  Retrieve the information for a specific group name or guid.

## Source Code

    module.exports = shy: true, handler: (options, callback) ->
      @log message: "Entering etc_group.read", level: 'DEBUG', module: 'nikita/lib/system/etc_group/read'
      options.target ?= '/etc/group'
      # Retrieve groups from cache
      groups = null
      @call
        if: options.cache and !!@store['nikita:etc_group']
      , ->
        @log message: "Get group definition from cache", level: 'INFO', module: 'nikita/lib/system/etc_group/read'
        groups = @store['nikita:etc_group']
      # Read system groups and place in cache if requested
      @fs.readFile
        unless: options.cache and !!@store['nikita:etc_group']
        target: options.target
        encoding: 'ascii'
      , (err, content) ->
        throw err if err
        return unless content?
        groups = {}
        for line in string.lines content
          line = /(.*)\:(.*)\:(.*)\:(.*)/.exec line
          continue unless line
          groups[line[1]] = group: line[1], password: line[2], gid: parseInt(line[3]), user_list: if line[4] then line[4].split ',' else []
        @store['nikita:etc_group'] = groups if options.cache
      # Pass the group information
      @next (err) ->
        return callback err if err
        return callback null, true, groups unless options.gid
        return callback null, true, groups[options.gid] if groups[options.gid]?
        options.gid = parseInt options.gid, 10 if typeof options.gid is 'string' and /\d+/.test options.gid
        group = Object.values(groups).filter((group) -> group.gid is options.gid)[0]
        return callback Error "Invalid Option: no gid matching #{JSON.stringify options.gid}" unless group
        callback null, true, group
      
## Dependencies

    string = require '../../../misc/string'
