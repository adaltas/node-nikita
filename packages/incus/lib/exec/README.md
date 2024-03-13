
# `nikita.incus.exec`

Execute command in containers.

## Example

```js
const {$status, stdout, stderr} = await nikita.incus.exec({
  container: "my-container",
  command: "whoami"
})
console.info(`Command was executed: ${$status}`)
console.info(stdout)
```

## Todo

* Support `env` option
