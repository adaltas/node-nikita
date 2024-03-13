
# `nikita.incus.cluster.delete`

Delete a cluster of LXD instances.

## Example

```yaml
networks:
  incusbr0public: {}
  incusbr1private: {}
containers:
  nikita:
    image: "images:centos/7"
predelete: path/to/action
```
