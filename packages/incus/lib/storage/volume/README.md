
# `nikita.incus.storage.volume`

Create a new storage volume in the selected pool.

## Output parameters

* `$status`
  True if the volume was created.

To create a volume in NikitaLXD, the `incus.storage.volume` package 
exists. Creating a volume needs some parameters:

  - name, which is the name of the volume;
  - pool, which is the storage pool to use;
  - content, which is the type (block or filesystem);
  - properties, which is the size of the volume, its limits, etc...

## Example of usage

```coffee
await nikita.incus.storage.volume({
    name: "volume_name",
    pool: "pool_name",
    content: "block",
    properties: {
      size: "50GiB"
    },
})
console.info(`The volume was correctly made: ${$status}`)
```

Once the volume has been created, it is associated with the targetd desired instance. 
The procedure to attach a volume depends on the type, as block volumes 
attachment do not require a location to mount the volume in the instance. 
However, for filesystem volumes attachment, a location is required. 
This is done with the `incus.storage.volume.attach` action, or at the instance's
creation through the `disk` property.

```js
nikita.incus.storage.attach({
  pool: 'pool_name',
  name: 'device_name',
  container: 'instance_name',
  device: 'device_name',
})
```

```yaml
disk:
  "device_name": 
    pool: pool_name,
    source: volume_name
```
