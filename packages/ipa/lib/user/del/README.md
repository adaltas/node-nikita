
# `nikita.ipa.user.del`

Delete a user from FreeIPA.

## Example

```js
const {$status} = await nikita.ipa.user.del({
  uid: "someone",
  connection: {
    url: "https://ipa.domain.com/ipa/session/json",
    principal: "admin@DOMAIN.COM",
    password: "mysecret"
  }
})
console.info(`User was deleted: ${$status}`)
```
