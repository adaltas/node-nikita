
# `nikita.tools.sysctl.file`

Write or merge a sysctl configuration file and configure kernel parameters at runtime.

The target file is overwritten by default. The `merge` option preserves existing variables.

Comments are preserved if the `comments` and `merge` config are enabled.

## Output

* `$status`  (boolean)   
  Value is `true` if the property was created or updated.

## Example

```js
const {$status} = await nikita.tools.sysctl.file({
  source: '/etc/sysctl.conf',
  properties: {
    'vm.swappiness': 1
  }
})
console.info(`Systcl was reloaded: ${$status}`)
```

## Usefull Commands

* Display all sysctl variables   
  `sysctl -a`
* Display value for a kernel variable   
  `sysctl -n kernel.hostname`
* Set a kernel variable
  `echo "value" > /proc/sys/location/variable`
  `echo 'variable = value' >> /etc/sysctl.conf && sysctl -p`
  `echo '0' > /proc/sys/fs/protected_regular && sysctl -p && sysctl -a | grep 'fs.protected_regular = 0'`

## Note

Alternatively, we could write directly to "/proc" with `sysctl -w <property>="<value>"`
