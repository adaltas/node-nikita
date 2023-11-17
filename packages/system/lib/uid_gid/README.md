
# `nikita.system.uid_gid`

Normalize the "uid" and "gid" properties. A username defined by the "uid" option will
be converted to a Unix user ID and a group defined by the "gid" option will
be converted to a Unix group ID.    

At the moment, this only work with Unix username because it only read the
"/etc/passwd" file. A future implementation might execute a system command to
retrieve information from external identity providers.   

## Exemple

```js
const {uid, gid} = await nikita.system.uid_gid({
  uid: 'myuser',
  gid: 'mygroup'
})
console.info(`User uid is ${config.uid}`)
console.info(`Group gid is ${config.gid}`)
```
