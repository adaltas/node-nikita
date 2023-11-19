
# Nikita "system" package

The "system" package provides Nikita actions for various system management operations.

## Usage

```js
import "@nikitajs/system/register";
import nikita from "@nikitajs/core";

const {$status} = await nikita.system.user({
  username: "gollum",
  shell: "/bin/bash",
  system: true,
});
console.info("User was modified:", $status);
```
