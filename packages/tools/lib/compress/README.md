
# `nikita.tools.compress`

Compress an archive. Multiple compression types are supported. Unless
specified as an option, format is derived from the source extension. At the
moment, supported extensions are '.tgz', '.tar.gz', 'tar.xz', 'tar.bz2' and '.zip'.

## Output

* `$status`   
  Value is "true" if file was compressed.   

## Example

```js
const {$status} = await nikita.tools.compress({
  source: '/path/to/file.tgz'
  destation: '/tmp'
})
console.info(`File was compressed: ${$status}`)
```
