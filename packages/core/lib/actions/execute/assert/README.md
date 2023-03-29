
# `nikita.execute.assert`

Assert the execution or the output of a command.

## Configuration

All configuration properties are passed to `nikita.execute`.

## Assert a command succeed

```js
const {$status} = await nikita.execute.assert({
  command: 'exit 0'
})
console.info(`Command was succeeded: ${$status}`)
```

## Assert a command stdout

```js
const {$status} = await nikita.execute.assert({
  command: 'echo hello',
  assert: 'hello'
})
console.info(`Stdout was asserted: ${$status}`)
```
