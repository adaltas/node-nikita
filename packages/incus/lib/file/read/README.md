
# `nikita.incus.file.read`

Read the content of a file in a container.

## Example

```js
const {data} = await nikita.incus.file.read({
  container: 'my_container',
  target: '/root/a_file'
})
console.info(`File content: ${data}`)
```
