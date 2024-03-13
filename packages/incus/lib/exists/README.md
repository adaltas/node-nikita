
# `nikita.incus.exists`

Check if the container exists. If a container does not exists, the output value `exists` equals `false` and the action is not rejected.

## Output

* `exists`
  True if the device exist, false otherwise.

## Short usage example

```js
const {$status, config} = await nikita.incus.exists("my_container")
console.info($status ? `Container exists` : 'Container does not exists')
```
