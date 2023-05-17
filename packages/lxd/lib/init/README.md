
# `nikita.lxc.init`

Initialize a Linux Container with given image name, container name and config.

## Output

* `$status`
  Was the container successfully created

## Example

```js
const {$status} = await nikita.lxc.init({
  image: "ubuntu:18.04",
  container: "my_container"
})
console.info(`Container was created: ${$status}`)
```

## Implementation details

The current version 3.18 of lxd has an issue with lxc init waiting for
configuration from stdin when there is no tty. This used to work before. Use
`[ -t 0 ] && echo 'tty' || echo 'notty'` to detect the tty. The current
fix is to prepend the init command with `echo '' | `.

## TODO

We do not honors the configuration (`-c`) argument. Use the `lxc.config.set` for
now.
