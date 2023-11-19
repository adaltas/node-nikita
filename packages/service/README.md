
# Nikita "service" package

The "service" package provides Nikita actions for various service management operations.

## Usage

```js
import "@nikitajs/service/register";
import nikita from "@nikitajs/core";

const {$status} = await nikita.service({
  name: "nginx-light",
  srv_name: "nginx",
  chk_name: "nginx",
  state: "started",
});
console.info("Network available on first connection attempt:", !$status);
```
