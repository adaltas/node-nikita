
# `nikita.execute.wait`

Run a command periodically and continue once the command succeed.

Status equals `false` if the user command succeed right away, considering that no
change occured. Otherwise it equals `true`.   

## Example

```js
const {$status} = await nikita.execute.wait({
  command: "test -f /tmp/sth"
})
console.info(`Command succeed, the file "/tmp/sth" now exists: ${$status}`)
```

## Multiple commands

The command option accept an array of commands. Commands are executed sequentially. Note, the waiting interval applies between retries, not between command execution. This example wait for two files to be created:

```js
await nikita.execute.wait({
  command: [
    "test -d #{tmpdir}/file_1"
    "test -d #{tmpdir}/file_2"
  ],
  interval: 1000
})
```

## Reaching quorum

By default, all commands must succeed before pursuing. It is possible to stop waiting for commands once a quorum is reached.
