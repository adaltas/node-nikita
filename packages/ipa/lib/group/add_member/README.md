
# `nikita.ipa.group.add_member`

Add member to a group in FreeIPA.

## Example

```js
const {$status} = await nikita.ipa.group.add_member({
  cn: "somegroup",
  attributes: {
    user: ["someone"]
  },
  connection: {
    url: "https://ipa.domain.com/ipa/session/json",
    principal: "admin@DOMAIN.COM",
    password: "mysecret"
  }
})
console.info(`Member was added to the group: ${$status}`)
```
