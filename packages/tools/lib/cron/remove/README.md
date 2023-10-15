
# `nikita.tools.cron.remove`

Remove job(s) on crontab.

## Example

```js
const {$status} = await nikita.cron.remove({
  command: 'kinit service/my.fqdn@MY.REALM -kt /etc/security/service.keytab',
  when: '0 */9 * * *',
  user: 'service'
})
console.info(`Cron entry was removed: ${$status}`)
```
