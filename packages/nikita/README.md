
# Nikita

Automation and deployment solution of applications and infrastructures.

## Example

```js
import nikita from "nikita";

await nikita.log
  .cli()
  .file.download({
    $header: "Download",
    source: "http://download.redis.io/redis-stable.tar.gz",
    target: "redis-stable.tar.gz",
    cache: true,
    cache_dir: "/tmp/.cache",
  })
  .execute({
    $header: "Compile",
    $unless_exists: "redis-stable/src/redis-server",
    command: `
    tar xzf ./redis-stable.tar.gz
    cd redis-stable
    make
    `,
  })
  .file.properties({
    $header: "Configure",
    target: "conf/redis.conf",
    separator: " ",
    content: {
      bind: "127.0.0.1",
      "protected-mode": "yes",
      port: 6379,
    },
  })
  .execute({
    $debug: true,
    $header: "Start",
    // bash: true,
    code: [0, 42],
    command: `
    ./redis-stable/src/redis-cli ping && exit 42
    nohup ./redis-stable/src/redis-server conf/redis.conf &
    `,
  });
```
