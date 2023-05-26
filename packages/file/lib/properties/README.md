
# `nikita.file.properties`

Write a file in the Java properties format.

## Example

Use a custom delimiter with spaces around the equal sign.

```js
const {$status} = await nikita.file.properties({
  target: "/path/to/target.json",
  content: { key: "value" },
  separator: ' = '
  merge: true
})
console.info(`File was written: ${$status}`)
```
