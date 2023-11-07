
# `nikita.ipa.user.disable`

Disable a user from FreeIPA. Status is false if the user is already disabled.

## Example

```js
const {$status} = await nikita.ipa.user.disable({
  uid: "someone",
  connection: {
    url: "https://ipa.domain.com/ipa/session/json",
    principal: "admin@DOMAIN.COM",
    password: "mysecret"
  }
})
console.info(`User was disable: ${$status}`)
```
