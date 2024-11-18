# `nikita.incus.exec`

Execute a command inside the targeted container.

## Example

```js
const { $status, stdout, stderr } = await nikita.incus.exec({
  name: "my-container",
  command: "whoami",
});
console.info(`Command was executed: ${$status}`);
console.info("stdout:", stdout);
console.info("stderr:", stderr);
```

## Todo

- Support `env` option
