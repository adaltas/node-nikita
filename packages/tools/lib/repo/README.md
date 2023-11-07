
# `nikita.tools.repo`

Setup packet manager repository. Only support yum for now.

## Example

```js
const {$status} = await nikita.tools.repo({
  source: '/tmp/centos.repo',
  clean: 'CentOs*'
})
console.info(`Repo was updated: ${$status}`)
```
