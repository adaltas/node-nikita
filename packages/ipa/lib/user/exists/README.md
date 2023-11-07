
# `nikita.ipa.user.exists`

Check if a user exists inside FreeIPA.

## Example

```js
const {$status} = await nikita.ipa.user.exists({
  uid: 'someone',
  connection: {
    url: "https://ipa.domain.com/ipa/session/json",
    principal: "admin@DOMAIN.COM",
    password: "mysecret"
  }
})
console.info(`User exists: ${$status}`)
```
