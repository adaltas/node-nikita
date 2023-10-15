
# `nikita.tools.cron.add`

Register a job on crontab.

## Example

```js
const {$status} = await nikita.cron.add({
  command: 'kinit service/my.fqdn@MY.REALM -kt /etc/security/service.keytab',
  when: '0 */9 * * *',
  user: 'service'
})
console.info(`Cron entry created or modified: ${$status}`)
```
