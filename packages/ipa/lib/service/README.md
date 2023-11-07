
# `nikita.ipa.service`

Add a service in FreeIPA.

## Example

```js
const {$status} = await nikita.ipa.service({
  principal: "myprincipal/my.domain.com"
  },
  connection: {
    url: "https://ipa.domain.com/ipa/session/json",
    principal: "admin@DOMAIN.COM",
    password: "mysecret"
  }
})
console.info(`Service was updated: ${$status}`)
```
