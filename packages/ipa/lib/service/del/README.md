
# `nikita.ipa.service.del`

Delete a service from FreeIPA.

## Example

```js
const {$status} = await nikita.ipa.service.del({
  principal: "myprincipal/my.domain.com",
  connection: {
    url: "https://ipa.domain.com/ipa/session/json",
    principal: "admin@DOMAIN.COM",
    password: "mysecret"
  }
})
console.info(`Service was deleted: ${$status}`)
```
