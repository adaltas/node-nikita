
# `nikita.file.cson`

Write content in the CSON format.

## Output

* `err`   
  Error object if any.   
* `written`   
  Number of written actions with modifications.   

## Example

```js
const {$status} = await nikita.file.cson({
  content: {
    'my_key': 'my value'
  },
  target: '/tmp/my_file'
})
console.info(`Content was created: ${$status}`)
```
