
# `nikita.tools.sysctl.file.read`

Read a sysctl configuration file. Optionnaly, the `comment` option preserve comment as well as properties.

The returned `data` property contains an object whose keys map tp the sysctl properties. Values are returned as strings.

## Output

* `$status`  (boolean)   
  Value is always `false`.
* `data` (object)   
  Object whose keys map to the sysctl properties.

## Example

```js
const {data} = await nikita.tools.sysctl.file.read({
  source: '/etc/sysctl.conf',
  comments: true
})
console.info(data)
```
