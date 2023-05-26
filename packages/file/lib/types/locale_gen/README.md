
# `nikita.file.types.locale_gen`

Update the locale definition file located in "/etc/locale.gen".

## Example

```js
const {$status} = await nikita.file.types.locale_gen({
  target: '/etc/locale.gen',
  rootdir: '/mnt',
  locales: ['fr_FR.UTF-8', 'en_US.UTF-8']
})
console.info(`File was updated: ${$status}`)
```
