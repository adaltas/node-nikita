
# `nikita.fs.chmod`

Change the permissions of a file or directory.

## Output

* `err`   
  Error object if any.   
* `status`   
  Value is "true" if file permissions was created or modified.   

## Example

```js
const {$status} = await nikita.fs.chmod({
  target: '~/my/project',
  mode: 0o755
})
console.info(`Permissions were modified: ${$status}`)
```
