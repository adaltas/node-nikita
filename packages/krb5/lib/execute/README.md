
# `nikita.krb5.execute`

Execute a Kerberos command.

## Example

```js
const {$status} = await nikita.krb5.exec({
  command: 'listprincs'
})
console.info(`Command was executed: ${$status}`)
```
