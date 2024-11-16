# `nikita.incus.project.exists`

Check if an Incus project exists.

## Output

* `exists`
  True if the project exist, false otherwise.

## Short usage example

```js
const {exists} = await nikita.incus.project.exists("my_project")
console.info($status ? `Container exists` : 'Container does not exists')
```

## Example

```js
const { projects } = await nikita.incus.project.list();
console.info(`Available project:`);
projects.forEach((project) => console.info(`- ${project}`));
```
