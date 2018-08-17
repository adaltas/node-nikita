
# `nikita.system.etc_group.read`

Read and parse the group definition file located in "/etc/group".

## Options

* `cache` (boolean)   
  Cache the result inside the store.
* `target` (string)   
  Path to the group definition file, default to "/etc/group".
* `gid` (string|integer)   
  Retrieve the information for a specific group name or guid.

## Output parameters

* `groups`   
  An object where keys are the group names and values are the groups properties.
  See the parameter `group` for a list of available properties.
* `group`
  Properties associated witht the group, only if the input parameter `gid` is
  provided. Available properties are:   
  * `group` (string)   
  Name of the group.
  * `password` (string)   
  Group password as a result of the `crypt` function, rarely used.
  * `gid` (string)   
  The numerical equivalent of the group name. It is used by the operating
  system and applications when determining access privileges.
  * `users` (array[string])   
  List of users who are members of this group.

## Examples

Retrieve all groups informations:

```js
require('nikita')
.file.types.etc_group.read(function(err, {groups}){
  assert(Array.isArray(groups), true)
})
```

Retrieve information of an individual group:

```js
require('nikita')
.file.types.etc_group.read({
  gid: 0
}, function(err, {group}){
  assert(group.gid, 0)
  assert(group.group, 'root')
})
```

## Source Code

    module.exports = shy: true, handler: ({options}, callback) ->
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
        log: if typeof options.log is 'boolean' then options.log else false
      , (err, {data}) ->
        throw err if err
        return unless data?
        groups = {}
        for line in string.lines data
          line = /(.*)\:(.*)\:(.*)\:(.*)/.exec line
          continue unless line
          groups[line[1]] = group: line[1], password: line[2], gid: parseInt(line[3]), users: if line[4] then line[4].split ',' else []
        @store['nikita:etc_group'] = groups if options.cache
      # Pass the group information
      @next (err) ->
        return callback err if err
        return callback null, status: true, groups: groups unless options.gid
        return callback null, status: true, group: groups[options.gid] if groups[options.gid]?
        options.gid = parseInt options.gid, 10 if typeof options.gid is 'string' and /\d+/.test options.gid
        group = Object.values(groups).filter((group) -> group.gid is options.gid)[0]
        return callback Error "Invalid Option: no gid matching #{JSON.stringify options.gid}" unless group
        callback null, status: true, group: group
      
## Dependencies

    string = require '../../../misc/string'
