# `nikita.incus.project.list`

List Incus projects.

## Output

- `$status`  
  Always `true` if the command succeed.
- `projects`  
  List of registered projects.

## Example

```js
const { projects } = await nikita.incus.project.list();
console.info(`Available project:`);
projects.forEach((project) => console.info(`- ${project}`));
```
