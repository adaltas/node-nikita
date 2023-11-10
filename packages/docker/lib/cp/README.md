
# `nikita.docker.cp`

Copy files/folders between a container and the local filesystem.

Reflecting the original docker ps command usage, source and target may take
the following forms:

* CONTAINER:PATH 
* LOCALPATH
* process.readableStream as the source or process.writableStream as the
  target (equivalent of "-")

Note, stream are not yet supported.

## Uploading a file

```js
const {$status} = await nikita.docker.cp({
  source: readable_stream or '/path/to/source'
  target: 'my_container:/path/to/target'
})
console.info(`Container was copied: ${$status}`)
```

## Downloading a file

```js
const {$status} = await nikita.docker.cp({
  source: 'my_container:/path/to/source',
  target: writable_stream or '/path/to/target'
})
console.info(`Container was copied: ${$status}`)
```
