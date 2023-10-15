
# `nikita.tools.sysctl`

Configure kernel parameters at runtime.

Target file will be overwritten by default, use the `merge` option to preserve existing variables.

Comments will be preserved if the `comments` and `merge` config are enabled.

## Output

* `$status`  (boolean)   
  Value is `true` if the property was created or updated.

## Usefull Commands

* Display all sysctl variables   
  `sysctl -a`
* Display value for a kernel variable   
  `sysctl -n kernel.hostname`
* Set a kernel variable
  `echo "value" > /proc/sys/location/variable`
  `echo 'variable = value' >> /etc/sysctl.conf && sysctl -p`
  `echo '0' > /proc/sys/fs/protected_regular && sysctl -p && sysctl -a | grep 'fs.protected_regular = 0'`

## Example

```js
const {$status} = await nikita.tools.sysctl({
  source: '/etc/sysctl.conf',
  properties: {
    'vm.swappiness': 1
  }
})
console.info(`Systcl was reloaded: ${$status}`)
```
