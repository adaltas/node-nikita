
# `nikita.fs.exists`

Retrieve file information. If path is a symbolic link, then the link itself is
stat-ed, not the file that it refers to.

## Output

The returned object contains the properties:

* `exists` (boolean)
  Indicates if the target file exists.
* `target` (string)   
  Location of the target file.

## Example

```js
const {exists} = await nikita.fs.exists({
  target: '/path/to/file'
});
console.info(`File exists: ${exists}`);
```
