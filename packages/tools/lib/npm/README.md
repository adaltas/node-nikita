
# `nikita.tools.npm`

Install Node.js packages with NPM.

It upgrades outdated packages if config "upgrade" is "true".

## Example

The following action installs the coffescript package globally.

```js
const {$status} = await nikita.tools.npm({
  name: 'coffeescript',
  global: true
})
console.info(`Package was installed: ${$status}`)
```
