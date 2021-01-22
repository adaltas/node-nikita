
# `nikita.system.group.read`

Read and parse the group definition file located in "/etc/group".

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
.system.group.read(function(err, {groups}){
  assert(Array.isArray(groups), true)
})
```

Retrieve information of an individual group:

```js
require('nikita')
.system.group.read({
  gid: 0
}, function(err, {group}){
  assert(group.gid, 0)
  assert(group.group, 'root')
})
```

## Schema

    schema =
      type: 'object'
      properties:
        'gid':
          oneOf: [
            type: 'boolean'
          ,
            type: 'string'
          ]
          default: false
          description: '''
          Retrieve the information for a specific group name or guid.
          '''
        'target':
          type: 'string'
          description: '''
          Path to the group definition file, default to "/etc/group".
          '''

    handler = ({config, metadata, state, tools: {log}}) ->
      config.target ?= '/etc/group'
      # Read system groups
      {data} = await @fs.base.readFile
        target: config.target
        encoding: 'ascii'
      groups = {}
      for line in utils.string.lines data
        line = /(.*)\:(.*)\:(.*)\:(.*)/.exec line
        continue unless line
        groups[line[1]] = group: line[1], password: line[2], gid: parseInt(line[3]), users: if line[4] then line[4].split ',' else []
      # Pass the group information
      return groups: groups unless config.gid
      return group: groups[config.gid] if groups[config.gid]?
      config.gid = parseInt config.gid, 10 if typeof config.gid is 'string' and /\d+/.test config.gid
      group = Object.values(groups).filter((group) -> group.gid is config.gid)[0]
      throw Error "Invalid Option: no gid matching #{JSON.stringify config.gid}" unless group
      return group: group

## Exports

    module.exports =
      handler: handler
      metadata:
        schema: schema

## Dependencies

    utils = require '../utils'
