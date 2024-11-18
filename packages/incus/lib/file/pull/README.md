# `nikita.incus.file.pull`

Pull files from containers.

## Example

```js
const { $status } = await nikita.incus.file.pull({
  name: "my-container",
  source: "/root/a_file",
  target: `./folder/a_file`,
});
console.info("File was pulled", $status);
```
