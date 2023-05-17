
# `nikita.lxc.cluster.delete`

Delete a cluster of LXD instances.

## Example

```yaml
networks:
  lxdbr0public: {}
  lxdbr1private: {}
containers:
  nikita:
    image: "images:centos/7"
predelete: path/to/action
```
