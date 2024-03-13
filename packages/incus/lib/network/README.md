
# `nikita.incus.network`

Create a network or update a network configuration

## Output

* `$status`
  True if the network was created/updated

## Example

```js
const {$status} = await nikita.incus.network({
  network: 'lxbr0'
  properties: {
    'ipv4.address': '172.89.0.0/24',
    'ipv6.address': 'none'
  }
})
console.info(`Network was created: ${$status}`)
```
