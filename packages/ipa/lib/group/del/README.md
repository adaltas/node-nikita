
# `nikita.ipa.group.del`

Delete a group from FreeIPA.

## Example

```js
const {$status} = await nikita.ipa.group.del({
  cn: 'somegroup',
  connection: {
    url: "https://ipa.domain.com/ipa/session/json",
    principal: "admin@DOMAIN.COM",
    password: "mysecret"
  }
})
console.info(`Group was deleted: ${$status}`)
```
