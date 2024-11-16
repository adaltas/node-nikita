
# `nikita.incus.project`

Create a new Incus project.

## Output

* `$status`
  Was the container successfully created

## Example

```js
const {$status} = await nikita.incus.project({
  project: "my_project"
})
console.info(`Project was created: ${$status}`)
```
