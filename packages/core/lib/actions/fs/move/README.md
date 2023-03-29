
# `nikita.fs.move`

Move files and directories. It is ok to overwrite the target file if it
exists, in which case the source file will no longer exists.

## Output

* `err`   
  Error object if any.
* `status`   
  Value is "true" if resource was moved.

## Example

```js
const {$status} = await nikita.fs.move({
  source: __dirname,
  target: '/tmp/my_dir'
})
console.info(`Directory was moved: ${$status}`)
```
