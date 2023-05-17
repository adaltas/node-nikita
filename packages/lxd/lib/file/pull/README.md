# `nikita.lxc.file.pull`

Pull files from containers.

## Example

```js
const {$status} = await nikita.lxc.file.pull({
  container: 'my_container',
  source: '/root/a_file',
  target: `./folder/a_file`
})
console.info(`File was pulled: ${$status}`)
```
