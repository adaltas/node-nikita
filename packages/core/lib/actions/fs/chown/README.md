
# `nikita.fs.chown`

Change the ownership of a file or a directory.

## Output

* `err`   
  Error object if any.   
* `status`   
  Value is "true" if file ownership was created or modified.   

## Example

```js
const {$status} = await nikita.fs.chown({
  target: '~/my/project',
  uid: 'my_user',
  gid: 'my_group'
})
console.info(`Ownership was modified: ${$status}`)
```

## Note

To list all files owner by a user or a uid, run:

```bash
find /var/tmp -user `whoami`
find /var/tmp -uid 1000
find / -uid $old_uid -print | xargs chown $new_uid:$new_gid
```
