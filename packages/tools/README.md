
# Nikita "tools" package

The "tools" package provides Nikita actions for various CLI tools.

## Usage

```js
import "@nikitajs/tools/register";
import nikita from "@nikitajs/core";

const {$status} = await nikita.tools.git({
  source: "/tmp/super_project.git",
  target: "/tmp/super_project",
  revision: "v0.0.1",
});
console.info("Repository was modified:", $status);
```
