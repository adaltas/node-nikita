
# `nikita.fs.base.stat`

Retrieve file information.

## File information

The `mode` parameter indicates the file type. For conveniency, the
`@nikitajs/core/utils/stats` module provide functions to check each
possible file types.

## Example

Check if target is a file:

```js
import utils from '@nikitajs/core/utils';
const {stats} = await nikita
  .file.touch("/tmp/a_file")
  .fs.base.stat("/tmp/a_file");
assert(utils.stats.isFile(stats.mode) === true);
```

Check if target is a directory:

```js
import utils from '@nikitajs/core/utils';
const {stats} = await nikita
  .fs.base.mkdir("/tmp/a_file")
  .fs.base.stat("/tmp/a_file");
assert(utils.stats.isDirectory(stats.mode) === true);
```

## Note

The `stat` command return an empty stdout in some circounstances like uploading
a large file with `file.download`, thus the activation of `retry` and `sleep`
confguration properties.

## Schema definitions

The parameters include a subset as the one of the Node.js native 
[`fs.Stats`](https://nodejs.org/api/fs.html#fs_class_fs_stats) object.

TODO: we shall be able to reference this as a `$ref` once schema does apply to
returned values.

## Stat implementation

On Linux, the format argument is '-c'. The following codes are used:

- `%f`  The raw mode in hexadecimal.
- `%u`  The user ID of owner.
- `%g`  The group ID of owner.
- `%s`  The block size of file.
- `%X`  The time of last access, seconds since Epoch.
- `%y`  The time of last modification, human-readable.

On MacOS, the format argument is '-f'. The following codes are used:

- `%Xp` File type and permissions in hexadecimal.
- `%u`  The user ID of owner.
- `%g`  The group ID of owner.
- `%z`  The size of file in bytes.
- `%a`  The time file was last accessed.
- `%m`  The time file was last modified.
