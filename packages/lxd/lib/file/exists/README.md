
# `nikita.lxc.file.exists`

Check if the file exists in a container.

## Example

```js
const {$status} = await nikita.lxc.file.exists({
  container: 'my_container',
  target: '/root/a_file'
})
console.info(`File exists: ${$status}`)
```

## Todo

* Push recursive directories
* Handle unmatched target permissions
* Handle unmatched target ownerships
* Detect name from lxd_target

## Implementation change

Previous implementation used `lxc.query` action to retrieve the content of the 
file and then determine if it exists or not:

```bash
lxc query --request GET /1.0/instances/container_name/files?path=file_path
```

It presents two problems:

1. The file is fetch which introduce delay and be unacceptable for large file.
2. The current LXD version throw an error when the file is empty, see 
[LXD issue #11388](https://github.com/lxc/lxd/issues/11388).

The [LXD API](https://linuxcontainers.org/lxd/docs/latest/api/#/) exposes a
REST endpoint to obtain file metadata. However, lxc query don't support the 
HEAD HTTP method, see [LXD issue #11383](https://github.com/lxc/lxd/issues/11383).

This implementation uses the `lxc.exec` action to run the existence file test directly 
inside the container.
