
# `nikita.ipa.group.show`

Retrieve group information from FreeIPA.

## Example

```js
const {result} = await nikita.ipa.group.show({
  cn: 'somegroup',
  connection: {
    url: "https://ipa.domain.com/ipa/session/json",
    principal: "admin@DOMAIN.COM",
    password: "mysecret"
  }
})
console.info(`Group is ${result.cn[0]}`)
```
