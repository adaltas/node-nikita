
# Nikita "log" package

The "log" package provides Nikita actions for logging.

## Usage

```js
import "@nikitajs/log/register";
import nikita from "@nikitajs/core";

await nikita
  .log.cli()
  .log.csv({
    basedir: "~/.log",
  })
  .execute({
    $header: "Whoami",
    command: "whoami",
  });
```
