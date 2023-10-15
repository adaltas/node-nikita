
# `nikita.tools.npm.uninstall`

Remove one or more NodeJS packages.

## Example

The following action uninstalls the coffescript package globally.

```js
const {$status} = await nikita.tools.npm.uninstall({
  name: 'coffeescript',
  global: true
})
console.info(`Package was uninstalled: ${$status}`)
```
