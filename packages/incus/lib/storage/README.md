
# `nikita.incus.storage`

Create a storage or update a storage configuration.

## Output

* `$status`
  Was the storage created or updated

## Example

```js
const {$status} = await nikita.incus.storage({
  name: "system",
  driver: "zfs",
  properties: {
    source: "syspool/incus"
  }
})
console.info(`Storage was created or config updated: ${$status}`)
```
