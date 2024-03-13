
# `nikita.incus.cluster.stop`

Stop a cluster of LXD instances.

## Example

```yaml
containers:
  nikita:
    image: "images:centos/7"
wait: true
prestop: path/to/action
```
