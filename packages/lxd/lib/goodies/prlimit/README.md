
# `nikita.lxc.goodies.prlimit`

Print the process limit associated with a running container.

The action require the `prlimit` command to be available. On Ubuntu, use `apt
install util-linux`.

Note, the action must be executed on the host container of the machine. When
using a remote LXD server or cluster, you must know on which node the machine is running
and run the action in this node.

## Output

* `error` (object)
  The error object, if any.
* `output.stdout` (string)
  The standard output from the `prlimit` command.
* `output.limits` (array)
  The limit object parsed from `stdout`; each element of the array contains the
  keys `resource`, `description`, `soft`, `hard` and `units`.

## Example

```js
const {stdout, limits} = await nikita.lxc.goodies.prlimit({
  container: "my_container"
})
console.info( `${stdout} ${JSON.decode(limits)}`)
```
