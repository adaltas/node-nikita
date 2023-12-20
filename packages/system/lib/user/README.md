
# `nikita.system.user`

Create or modify a Unix user.

If the user home is provided, its parent directory will be created with root 
ownerships and 0644 permissions unless it already exists.

## Callback parameters

* `$status`   
  Value is "true" if user was created or modified.

## Example

```js
const {$status} = await nikita.system.user({
  name: 'a_user',
  system: true,
  uid: 490,
  gid: 10,
  comment: 'A System User'
})
console.info(`User created: ${$status}`)
```

The result of the above action can be viewed with the command
`cat /etc/passwd | grep myself` producing an output similar to
"a\_user:x:490:490:A System User:/home/a\_user:/bin/bash". You can also check
you are a member of the "wheel" group (gid of "10") with the command
`id a\_user` producing an output similar to 
"uid=490(hive) gid=10(wheel) groups=10(wheel)".
