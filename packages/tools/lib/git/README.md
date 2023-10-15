
# `nikita.tools.git`

Create and synchronize a git repository.

## Output

* `$status`   
  Value "true" if repository was created or modified.

## Example

The following action make sure the git repository is synchronized to the latest
HEAD revision.

```js
const {$status} = await nikita.tools.git({
  source: 'https://github.com/adaltas/node-nikita.git'
  target: '/tmp/nikita'
})
console.info(`Repo was synchronized: ${$status}`)
```
