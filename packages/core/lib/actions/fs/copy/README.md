
# `nikita.fs.copy`

Copy a file. The behavior is similar to the one of the `cp`
Unix utility. Copying a file over an existing file will
overwrite it.

## Output

* `err`   
  Error object if any.   
* `status`   
  Value is "true" if copied file was created or modified.   

## Todo

* Apply permissions to directories
* Handle symlinks
* Handle globing
* Preserve permissions if `mode` is `true`

## Example

```js
const {$status} = await nikita.fs.copy({
  source: '/etc/passwd',
  target: '/etc/passwd.bck',
  uid: 'my_user',
  gid: 'my_group',
  mode: '0755'
})
console.info(`File was copied: ${$status}`)
```
