# `nikita.incus.project.exists`

Check if an Incus project exists.

## Output

* `exists`
  True if the project exist, false otherwise.

## Example

```js
const {exists} = await nikita.incus.project.exists("my_project")
console.info($status ? `Container exists` : 'Container does not exists')
```
