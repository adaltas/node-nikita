
# `nikita.execute.wait`

Run a command periodically and continue once the command succeed. Status will be
set to "false" if the user command succeed right away, considering that no
change had occured. Otherwise it will be set to "true".   

## Example

```js
const {$status} = await nikita.execute.wait({
  command: "test -f /tmp/sth"
})
console.info(`Command succeed, the file "/tmp/sth" now exists: ${$status}`)
```
