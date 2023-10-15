
# `nikita.tools.backup`

Backup a file, a directory or the output of a command.

## Output

* `$status`  (boolean)   
  Value is "true" if backup was created.   
* `base_dir` (string)   
* `name` (string)   
* `filename` (string)   
* `target` (string)   

## Example

Backup a directory:

```js
const {$status} = await nikita.tools.backup({
  name: 'my_backup',
  source: '/etc',
  target: '/tmp/backup',
  algorithm: 'gzip',  # Value are "gzip", "bzip2", "xz" or "none"
  extension: 'tgz'
  // retention: {
  //  count: 3
  //  date: '2015-01-01-00:00:00'
  //  age: month: 2
  // }
})
console.info(`File was backed up: ${$status}`)
```

## Note

It might be worth to check [backmeup](https://github.com/adaltas/node-backmeup).
