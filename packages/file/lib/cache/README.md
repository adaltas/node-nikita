
# `nikita.file.cache`

Download a file and place it on a local or remote folder for later usage.

## Output

* `$status`   
  Value is "true" if cache file was created or modified.

## HTTP example

Cache can be used from the `file.download` action:

```js
const {$status} = await nikita.file.download({
  source: 'https://github.com/wdavidw/node-nikita/tarball/v0.0.1',
  cache_dir: '/var/tmp'
})
console.info(`File downloaded: ${$status}`)
```
