
# `nikita.file.properties.read`

Read a file in the Java properties format.

## Example

Use a custom delimiter with spaces around the equal sign.

```js
const {properties} = await nikita.file.properties.read({
  target: "/path/to/target.json",
  separator: ' = '
})
console.info(`Properties:`, properties)
```
