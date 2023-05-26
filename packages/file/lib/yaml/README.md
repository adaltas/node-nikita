
# `nikita.file.yaml`

Write an object serialized in YAML format. Note, we are internally using the [js-yaml] module.
However, there is a subtile difference. Any key provided with value of
`undefined` or `null` will be disregarded. Within a `merge`, it get more
prowerfull and tricky: the original value will be kept if `undefined` is
provided while the value will be removed if `null` is provided.

The `file.yaml` function rely on the `file` function and accept all of its
configuration. It introduces the `merge` option which instruct to read the
target file if it exists and merge its parsed object with the one
provided in the `content` option.

## Output

* `$status`   
  Indicate modifications in the target file.

## Example

```js
const {$status} = await nikita.file.yaml({
  content: {
    'my_key': 'my value'
  },
  target: '/tmp/my_file'
})
console.info(`Content was written: ${$status}`)
```
