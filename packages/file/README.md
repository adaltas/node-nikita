
# Nikita "file" package

The "file" package provides Nikita actions to work with files.

## Usage

```js
import "@nikitajs/file/register";
import nikita from "@nikitajs/core";

const {$status} = await nikita.file.yaml({
  content: {
    preference: {
      color: "orange",
    },
  },
  target: "~/config.yml"
});
console.info("File was modified:", $status);
```
