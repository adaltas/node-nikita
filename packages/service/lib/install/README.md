
# `nikita.service.install`

Install a service. Yum, Yay, Pacman and apt-get are supported.

## Output

* `$status`   
  Indicates if the service was installed.

## Example

```js
const {$status} = await nikita.service.install({
  name: 'ntp'
})
console.info(`Package installed: ${$status}`)
```
