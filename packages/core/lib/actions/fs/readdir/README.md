
# `nikita.fs.readdir`

Reads the contents of a directory. The implementation is conformed with the Node.js native [`fs.readir`](https://nodejs.org/api/fs.html#fs_fs_readdir_path_options_callback) function.
  
## Output parameters

* `files` ([fs.Dirent])   
  List of the names of the files in the directory excluding '.' and '..'

## Examples

Return an array of files if only the target options is provided:

```js
const {files} = await nikita
  .fs.base.mkdir('/parent/dir/a_dir')
  .fs.writeFile('/parent/dir/a_file', '')
  .fs.readdir("/parent/dir/a_dir");
assert(files, ['my_dir', 'my_file']);
```

Return an array of `Dirent` objects if the `withFileTypes` options is provided:

```js
const {files} = await nikita
  .fs.writeFile('/parent/dir/a_file', '')
  .fs.readdir({
    target: "/parent/dir/a_dir",
    withFileTypes: true
  });
assert(files[0].name, 'a_file');
assert(files[0].isFile(), true);
```
