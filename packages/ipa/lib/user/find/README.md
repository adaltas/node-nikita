
# `nikita.ipa.user.find`

Find the users registed inside FreeIPA. "https://ipa.domain.com/ipa/session/json"

## Example

```js
const {$status} = await nikita.ipa.user.find({
  criterias: {
    in_group: ["user_find_group"]
  }
  connection: {
    url: "https://ipa.domain.com/ipa/session/json",
    principal: "admin@DOMAIN.COM",
    password: "mysecret"
  }
})
console.info(`User was found: ${$status}`)
```
