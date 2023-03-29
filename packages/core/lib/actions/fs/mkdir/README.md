
# `nikita.fs.mkdir`

Recursively create a directory. The behavior is similar to the Unix command
`mkdir -p`. It supports an alternative syntax where config is simply the path
of the directory to create.

Permissions defined in the `mode` configuration are set on directory
creation. Use `force` to update the target directory if it exists and if its
value is different than expected. Parent directories are not impacted by
`force`. 

## Output

* `err`   
  Error object if any.   
* `status`   
  Value is "true" if directory was created or modified.   

## Simple usage

```js
const {$status} = await nikita.fs.mkdir('./some/dir')
console.info(`Directory was created: ${$status}`)
```

## Advanced usage

```js
const {$status} = await nikita.fs.mkdir({
  $ssh: ssh,
  target: './some/dir',
  uid: 'a_user',
  gid: 'a_group'
  mode: 0o0777 // or '777'
})
console.info(`Directory was created: ${$status}`)
```
