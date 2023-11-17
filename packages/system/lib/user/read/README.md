
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
const {$status, users} = await nikita
.file({
  target: "/tmp/etc/passwd",
  content: "root:x:0:0:root:/root:/bin/bash"
})
.system.user.read({
  target: "/tmp/etc/passwd"
})
assert.equal($status, false)
assert.deepEqual(users, {
  "root": { user: 'root', uid: 0, gid: 0, comment: 'root', home: '/root', shell: '/bin/bash' }
})
```

## Implementation

The default implementation use the `getent passwd` command. It is possible to
read an alternative `/etc/passwd` file by setting the `target` option to the
targeted file.
