
# `nikita.ipa.service.show`

Retrieve service information from FreeIPA.

## Example

```js
try {
  const {result} = await nikita.ipa.service.show({
    principal: "myprincipal/my.domain.com",
    connection: {
      url: "https://ipa.domain.com/ipa/session/json",
      principal: "admin@DOMAIN.COM",
      password: "mysecret"
    }
  })
  console.info(`Service is ${result.principal[0]}`)
}
catch (err){
  switch(err.code){
    case 4001:
     assert("myprincipal/my.domain.com@DOMAIN.COM: service not found", err.message)
    break
  }
}  
```
