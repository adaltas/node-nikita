
# `nikita.system.user.read`

Read and parse the passwd definition file located in "/etc/passwd".

## Options

* `cache` (boolean, `false`, optional)   
  Cache the result inside the store.
* `target` (string, optional)   
  Path to the passwd definition file,use the `getent passwd` by default which
  use to "/etc/passwd".
* `uid` (string|integer)   
  Retrieve the information for a specific user name or uid.

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

## Source Code

    module.exports = shy: true, handler: ({metadata, options}, callback) ->
      @log message: "Entering system.user.read", level: 'DEBUG', module: 'nikita/lib/system/user/read'
      throw Error 'Invalid Option: uid must be a string or a number' if options.uid and not typeof options.uid in ['string', 'number']
      options.uid = parseInt options.uid, 10 if typeof options.uid is 'string' and /\d+/.test options.uid
      # Retrieve passwd from cache
      passwd = null
      @call
        if: options.cache and !!@store['nikita:etc_passwd']
      , ->
        @log message: "Get passwd definition from cache", level: 'INFO', module: 'nikita/lib/system/user/read'
        passwd = @store['nikita:etc_passwd']
      # Read system passwd and place in cache if requested
      str2passwd = (data) ->
        passwd = {}
        for line in string.lines data
          line = /(.*)\:\w\:(.*)\:(.*)\:(.*)\:(.*)\:(.*)/.exec line
          continue unless line
          passwd[line[1]] = user: line[1], uid: parseInt(line[2]), gid: parseInt(line[3]), comment: line[4], home: line[5], shell: line[6]
        passwd
      unless options.target
        @system.execute
          cmd: 'getent passwd'
        , (err, {stdout}) ->
          throw err if err
          passwd = str2passwd stdout
          @store['nikita:etc_passwd'] = passwd if options.cache
      else
        @fs.readFile
          unless: options.cache and !!@store['nikita:etc_passwd']
          target: options.target
          encoding: 'ascii'
          log: metadata.log
        , (err, {data}) ->
          throw err if err
          return unless data?
          passwd = str2passwd data
          @store['nikita:etc_passwd'] = passwd if options.cache
      # Pass the passwd information
      @next (err) ->
        return callback err if err
        return callback null, status: true, users: passwd unless options.uid
        if typeof options.uid is 'string'
          user = passwd[options.uid]
          return callback Error "Invalid Option: no uid matching #{JSON.stringify options.uid}" unless user
          callback null, status: true, user: user
        else
          user = Object.values(passwd).filter((user) -> user.uid is options.uid)[0]
          return callback Error "Invalid Option: no uid matching #{JSON.stringify options.uid}" unless user
          callback null, status: true, user: user
      
## Dependencies

    string = require '@nikitajs/core/lib/misc/string'
