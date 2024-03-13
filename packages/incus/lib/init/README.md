
# `nikita.incus.init`

Initialize a Linux Container with given image name, container name and config.

## Output

* `$status`
  Was the container successfully created

## Example

```js
const {$status} = await nikita.incus.init({
  image: "ubuntu:18.04",
  container: "my_container"
})
console.info(`Container was created: ${$status}`)
```

## Implementation details

The current version 3.18 of incus has an issue with incus init waiting for
configuration from stdin when there is no tty. This used to work before. Use
`[ -t 0 ] && echo 'tty' || echo 'notty'` to detect the tty. The current
fix is to prepend the init command with `echo '' | `.

## TODO

We do not honors the configuration (`-c`) argument. Use the `incus.config.set` for
now.
