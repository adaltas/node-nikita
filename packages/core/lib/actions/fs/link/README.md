
# `nikita.fs.link`

Create a symbolic link and it's parent directories if they don't yet
exist.

Note, it is valid for the "source" file to not exist.

## Output

* `err`   
  Error object if any.   
* `status`   
  Value is "true" if link was created or modified.   

## Example

```js
const {$status} = await nikita.fs.link({
  source: __dirname,
  target: '/tmp/a_link'
})
console.info(`Link was created: ${$status}`)
```
