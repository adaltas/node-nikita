# `nikita.incus.storage.show`

Show storage pool configurations and resources.

## Output

- `name`  
  The name of the storage pool.

## Example

```js
const { config } = await nikita.incus.storage.show({
  name: 'system'
});
console.info(`Storage configuration:', config);
```
