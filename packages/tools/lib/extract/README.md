
# `nikita.tools.extract`

Extract an archive. Multiple compression types are supported. Unless
specified as an option, format is derived from the source extension. At the
moment, supported extensions are '.tgz', '.tar.gz', tar.bz2, 'tar.xz' and '.zip'.

## Output

* `$status`   
  Value is "true" if archive was extracted.

## Example

```js
const {$status} = await nikita.tools.extract({
  source: '/path/to/file.tgz'
  destation: '/tmp'
})
console.info(`File was extracted: ${$status}`)
```
