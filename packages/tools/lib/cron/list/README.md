
# `nikita.tools.cron.list`

List jobs registered in crontab.

## Example

```js
const {$status} = await nikita.cron.list({
  when: '0 */9 * * *',
  user: 'service'
})
console.info(`Cron entry created or modified: ${$status}`)
```
