
# `nikita.ipa.user.enable`

Enable a user from FreeIPA. Status is false if the user is already enabled.

## Example

```js
const {$status} = await nikita.ipa.user.enable({
  uid: "someone",
  connection: {
    url: "https://ipa.domain.com/ipa/session/json",
    principal: "admin@DOMAIN.COM",
    password: "mysecret"
  }
})
console.info(`User was enable: ${$status}`)
```
