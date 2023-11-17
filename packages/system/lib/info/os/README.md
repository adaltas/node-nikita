
# `nikita.system.info.os`

Expose system information. Internally, it uses the command `uname` to retrieve
information.

## Todo

There are more properties exposed by `uname` such as the machine hardware name
and the hardware platform. Those properties shall be exposed.

We shall explain what "non-portable" means.

## Example

```js
const {os} = await nikita.system.info.os()
console.info('Architecture:', os.arch)
console.info('Distribution:', os.distribution)
console.info('Version:', os.version)
console.info('Linux version:', os.linux_version)
```
