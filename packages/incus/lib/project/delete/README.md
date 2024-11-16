# `nikita.incus.project.delete`

Delete an Incus project.

## Output

* `$status`  
  True if the project existed and is now deleted, false otherwise.

## Short usage example

```js
const {$status} = await nikita.incus.project.delete("my_project")
console.info($status ? `Container removed.` : 'Container was already removed.')
```
