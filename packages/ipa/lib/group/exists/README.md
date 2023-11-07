
# `nikita.ipa.group.exists`

Check if a group exists inside FreeIPA.

## Example

```js
const {$status} = await nikita.ipa.group.exists({
  cn: 'somegroup',
  connection: {
    url: "https://ipa.domain.com/ipa/session/json",
    principal: "admin@DOMAIN.COM",
    password: "mysecret"
  }
})
console.info(`Group exists: ${$status}`)
```
