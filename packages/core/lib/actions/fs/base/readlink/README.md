
# `nikita.fs.base.readlink`

Read a link and return its destination path.

## Example

```js
// Create and read a symbolink link
const {target} = await nikita
  .fs.base.symlink({
    source: "/tmp/a_source"
    target: "/tmp/a_target"
  })
  .fs.base.readlink({
    target: "/tmp/a_target"
  });
// Assert the destination path
assert.eql(target, "/tmp/a_source");
```
