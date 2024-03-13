
# `nikita.incus.file.exists`

Check if the file exists in a container.

## Example

```js
const {$status} = await nikita.incus.file.exists({
  container: 'my_container',
  target: '/root/a_file'
})
console.info(`File exists: ${$status}`)
```

## Todo

* Push recursive directories
* Handle unmatched target permissions
* Handle unmatched target ownerships
* Detect name from incus_target

## Implementation change

Previous implementation used `incus.query` action to retrieve the content of the 
file and then determine if it exists or not:

```bash
incus query --request GET /1.0/instances/container_name/files?path=file_path
```

It presents two problems:

1. The file is fetch which introduce delay and be unacceptable for large file.
2. The current LXD version throw an error when the file is empty, see 
[LXD issue #11388](https://github.com/incus/incus/issues/11388).

The [LXD API](https://linuxcontainers.org/incus/docs/latest/api/#/) exposes a
REST endpoint to obtain file metadata. However, incus query don't support the 
HEAD HTTP method, see [LXD issue #11383](https://github.com/incus/incus/issues/11383).

This implementation uses the `incus.exec` action to run the existence file test directly 
inside the container.
