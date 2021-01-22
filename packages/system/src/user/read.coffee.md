
# `nikita.system.user.read`

Read and parse the passwd definition file located in "/etc/passwd".

## Output parameters

* `users`   
  An object where keys are the usernames and values are the user properties.
  See the parameter `user` for a list of available properties.
* `user`
  Properties associated witht the user, only if the input parameter `uid` is
  provided. Available properties are:   
  * `user` (string)   
  Username.
  * `uid` (integer)   
  User Id.
  * `comment` (string)   
  User description
  * `home` (string)   
  User home directory.
  * `shell` (string)   
  Default user shell command.

## Example

```js
nikita
.file({
  target: "/tmp/etc/passwd",
  content: "root:x:0:0:root:/root:/bin/bash"
})
.system.user.read({
  target: "/tmp/etc/passwd"
}, function (err, {status, users}){
  if(err) throw err;
  assert(status, false)
  assert(users, {
    "root": { user: 'root', uid: 0, gid: 0, comment: 'root', home: '/root', shell: '/bin/bash' }
  })
});
```

## implementation

The default implementation use the `getent passwd` command. It is possible to
read an alternative `/etc/passwd` file by setting the `target` option to the
targeted file.

## Schema

    schema =
      'target':
        type: 'string'
        description: '''
        Path to the passwd definition file, use the `getent passwd` by default
        which use to "/etc/passwd".
        '''
      'uid':
        oneOf: [
          type: 'integer'
        ,
          type: 'string'
        ]
        description: '''
        Retrieve the information for a specific user name or uid.
        '''

## Handler

    handler = ({config}) ->
      config.uid = parseInt config.uid, 10 if typeof config.uid is 'string' and /\d+/.test config.uid
      # Read system passwd
      str2passwd = (data) ->
        passwd = {}
        for line in utils.string.lines data
          line = /(.*)\:\w\:(.*)\:(.*)\:(.*)\:(.*)\:(.*)/.exec line
          continue unless line
          passwd[line[1]] = user: line[1], uid: parseInt(line[2]), gid: parseInt(line[3]), comment: line[4], home: line[5], shell: line[6]
        passwd
      unless config.target
        {stdout} = await @execute
          command: 'getent passwd'
        passwd = str2passwd stdout
      else
        {data} = await @fs.base.readFile
          target: config.target
          encoding: 'ascii'
        # return unless data?
        passwd = str2passwd data
      # Pass the passwd information
      return users: passwd unless config.uid
      if typeof config.uid is 'string'
        user = passwd[config.uid]
        throw Error "Invalid Option: no uid matching #{JSON.stringify config.uid}" unless user
        user: user
      else
        user = Object.values(passwd).filter((user) -> user.uid is config.uid)[0]
        throw Error "Invalid Option: no uid matching #{JSON.stringify config.uid}" unless user
        user: user

## Exports

    module.exports =
      handler: handler
      metadata:
        schema: schema
        shy: true

## Dependencies

    utils = require '../utils'
