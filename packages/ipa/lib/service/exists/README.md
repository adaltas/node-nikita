
# `nikita.ipa.service.exists`

Check if a service exists inside FreeIPA.

## Example

```js
const {$status} = await nikita.ipa.service.exists({
  principal: 'myprincipal/my.domain.com',
  connection: {
    url: "https://ipa.domain.com/ipa/session/json",
    principal: "admin@DOMAIN.COM",
    password: "mysecret"
  }
})
console.info(`Service exists: ${$status}`)
```
