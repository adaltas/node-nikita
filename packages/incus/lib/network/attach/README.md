
# `nikita.incus.network.attach`

Attach an existing network to a container.

## Output

* `$status`   
  True if the network was attached.

## Example

```js
const {$status} = await nikita.incus.network.attach({
  network: 'network0',
  container: 'container1'
})
console.info(`Network was attached: ${$status}`)
```
