
# Nikita "network" package

The "network" package provides Nikita actions for networking operations.

## Usage

```js
import "@nikitajs/network/register";
import nikita from "@nikitajs/core";

const {$status} = await nikita.network.tcp.wait({
  server: [
    { host: 'localhost', port: 8080 },
    { host: 'localhost', port: 8081 },
    { host: 'localhost', port: 8082 },
  ],
  quorum: true,
  interval: 200,
});
console.info("Network available on first connection attempt:", !$status);
```
