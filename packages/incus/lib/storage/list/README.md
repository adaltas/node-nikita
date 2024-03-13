
# `nikita.incus.storage.list`

List available storage pools.

This is a `shy` action. As such, it does not modify the state.

## Configuration

The action doesn't accept any property.

## Example

```js
const {storages} = await nikita.incus.storage.list()
console.info(`Available storages: ${storages.map(', ')}`)
```

The `storages` object looks like:

```json
[
  {
    "config": {
      "source": "incus",
      "volatile.initial_source": "incus",
      "zfs.pool_name": "incus"
    },
    "description": "",
    "driver": "zfs",
    "locations": [
      "none"
    ],
    "name": "default",
    "status": "Created",
    "used_by": [
      "/1.0/images/1d5cd7f7619a797817839f65120f3d318eef2bf9a3c50dfcb4cb90fe24013475",
      "/1.0/images/2ae4207c94571f7d21aad07b9ffb71ff30c1e4617c87da64e2e745c0e62d6718",
      "/1.0/instances/nikita-config-device-1",
      "/1.0/profiles/default"
    ]
  },
  {
    "config": {
      "size": "19GiB",
      "source": "/var/snap/incus/common/incus/disks/nikita-storage-list-1.img",
      "zfs.pool_name": "nikita-storage-list-1"
    },
    "description": "",
    "driver": "zfs",
    "locations": [
      "none"
    ],
    "name": "nikita-storage-list-1",
    "status": "Created",
    "used_by": null
  }
]
```
