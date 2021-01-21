
# `nikita.fs.chown`

Change the ownership of a file or a directory.

## Output

* `err`   
  Error object if any.   
* `status`   
  Value is "true" if file ownership was created or modified.   

## Example

```js
const {status} = await nikita.fs.chown({
  target: '~/my/project',
  uid: 'my_user',
  gid: 'my_group'
})
console.info(`Ownership was modified: ${status}`)
```

## Note

To list all files owner by a user or a uid, run:

```bash
find /var/tmp -user `whoami`
find /var/tmp -uid 1000
find / -uid $old_uid -print | xargs chown $new_uid:$new_gid
```

## Hook

    on_action = ({config, metadata}) ->
      config.target = metadata.argument if metadata.argument?
      # String to integer coercion
      config.uid = parseInt config.uid if (typeof config.uid is 'string') and /\d+/.test config.uid
      config.gid = parseInt config.gid if (typeof config.gid is 'string') and /\d+/.test config.gid

## Schema

    schema =
      type: 'object'
      properties:
        'gid':
          oneOf: [{type: 'integer'}, {type: 'string'}]
          description: """
          Unix group name or id who owns the target file.
          """
        'stats':
          typeof: 'object'
          description: """
          Stat object of the target file. Short-circuit to avoid fetching the
          stat object associated with the target if one is already available.
          """
        'target':
          type: 'string'
          description: """
          Location of the file which permissions will change.
          """
        'uid':
          oneOf: [{type: 'integer'}, {type: 'string'}]
          description: """
          Unix user name or id who owns the target file.
          """
      required: ['target']

## Handler

    handler = ({config, tools: {log}}) ->
      throw Error "Missing one of uid or gid option" unless config.uid? or config.gid?
      if config.uid?
        uid = if typeof config.uid is 'number' then config.uid
        else
          {stdout} = await @execute "id -u '#{config.uid}'"
          parseInt stdout.trim()
      if config.gid?
        gid = if typeof config.gid is 'number' then config.gid
        else
          {stdout} = await @execute "id -g '#{config.gid}'"
          parseInt stdout.trim()
      # Retrieve target stats
      if config.stats
        log message: "Stat short-circuit", level: 'DEBUG'
        stats = config.stats
      else {stats} = await @fs.base.stat config.target
      # Detect changes
      changes =
        uid: uid? and stats.uid isnt uid
        gid: gid? and stats.gid isnt gid
      if not changes.uid and not changes.gid
        log message: "Matching ownerships on '#{config.target}'", level: 'INFO', module: 'nikita/lib/chown'
        return false
      # Apply changes
      try
        await @fs.base.chown target: config.target, uid: uid, gid: gid
      catch err
        console.log err
      log message: "change uid from #{stats.uid} to #{uid}", level: 'WARN', module: 'nikita/lib/chown' if changes.uid
      log message: "change gid from #{stats.gid} to #{gid}", level: 'WARN', module: 'nikita/lib/chown' if changes.gid
      true

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        schema: schema
