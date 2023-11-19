
# `nikita.file.ini`

Write an object as .ini file. Note, we are internally using the [ini] module.
However, there is a subtle difference. Any key provided with value of 
`undefined` or `null` will be disregarded. Within a `merge`, it get more
prowerfull and tricky: the original value will be kept if `undefined` is
provided while the value will be removed if `null` is provided.

The `file.ini` function rely on the `file` function and accept all of its
configuration. It introduces the `merge` property which instruct to read the
target file if it exists and merge its parsed object with the one
provided in the `content` option.

## Options `stringify`   

Available values for the `stringify` option are:

* `stringify`
  Default, implemented by `nikita/file/utils/ini#stringify`

The default stringify function accepts:

* `separator` (string)   
  Characteres used to separate keys from values; default to " : ".

## Output

* `$status`   
  Indicate a change in the target file.

## Example

```js
const {$status} = await nikita.file.ini({
  content: {
    'my_key': 'my value'
  },
  target: '/tmp/my_file'
})
console.info(`Content was updated: ${$status}`)
```
