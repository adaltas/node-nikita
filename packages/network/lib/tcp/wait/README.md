
# `nikita.network.tcp.wait`

Check if one or multiple hosts listen one or multiple ports periodically and
continue once all the connections succeed. Status will be set to "false" if the
user connections succeed right away, considering that no change had occured.
Otherwise it will be set to "true".   

## Return

Status is set to "true" if the first connection attempt was a failure and the 
connection finaly succeeded.

## TODO

The `server` configuration property shall be renamed `address`.

## Examples

Wait for two domains on the same port.

```js
const {$status} = await nikita.network.tcp.wait({
  hosts: [ '1.domain.com', '2.domain.com' ],
  port: 80
})
console.info(`Servers listening on port 80: ${$status}`)
```

Wait for one domain on two diffents ports.

```js
const {$status} = await nikita.network.tcp.wait({
  host: 'my.domain.com',
  ports: [80, 443]
})
console.info(`Servers listening on ports 80 and 443: ${$status}`)
```

Wait for two domains on diffents ports.

```js
const {$status} = await nikita.network.tcp.wait({
  servers: [
    {host: '1.domain.com', port: 80},
    {host: '2.domain.com', port: 443}
  ]
})
console.info(`Servers listening: ${$status}`)
```
