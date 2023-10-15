
# `nikita.ssh.keygen`

Generates keys for use by SSH protocol version 2.

## Example

Force the generation of a key compatible with SSH2. For example in OSX Mojave,
the default export format is RFC4716.

```js
const {$status} = await nikita.tools.ssh.keygen({
  bits: 2048,
  comment: 'my@email.com',
  target: './id_rsa',
  key_format: 'PEM'
})
console.info(`Key was generated: ${$status}`)
```
