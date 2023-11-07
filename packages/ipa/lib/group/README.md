
# `nikita.ipa.group`

Add or modify a group in FreeIPA.

## Example

```js
const {$status} = await nikita.ipa.group({
  cn: 'somegroup',
  connection: {
    url: "https://ipa.domain.com/ipa/session/json",
    principal: "admin@DOMAIN.COM",
    password: "mysecret"
  }
})
console.info(`Group was updated: ${$status}`)
```
