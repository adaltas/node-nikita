
# `nikita.incus.network.detach`

Detach a network from a container.

## Output

* `$status`
  True if the network was detached

## Example

```js
const {$status} = await nikita.incus.network.detach({
  network: 'network0',
  container: 'container1'
})
console.info(`Network was detached: ${$status}`)
```
