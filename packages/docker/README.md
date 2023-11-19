
# Nikita "docker" package

The "docker" package provides Nikita actions for various Docker operations.

## Usage

```js
import "@nikitajs/docker/register";
import nikita from "@nikitajs/core";

const {stdout} = await nikita.docker.exec({
  container: "my_container"
  command: "whoami"
});
console.info(stdout);
```
