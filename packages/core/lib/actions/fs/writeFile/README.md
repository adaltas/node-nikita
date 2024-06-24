
# `nikita.fs.writeFile`

Write a Buffer or a string to a file. This action mimic the behavior of the
Node.js native [`fs.writeFile`](https://nodejs.org/api/fs.html#fs_fs_writefile_file_data_options_callback)
function.

Internally, it uses the `nikita.fs.createWriteStream` from which it inherits all
the configuration properties.

## Example

```js
nikita.fs.writeFile({
  target: "/tmp/a_file",
  content: 'Some data, a string or a Buffer'
});
```
