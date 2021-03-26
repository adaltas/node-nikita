
# `nikita.system.info.os`

Expose system information. Internally, it uses the command `uname` to retrieve
information.

## Options

There are no user option to this action.

## Callback

The following properties are available:

- `system.kernel_name` (string)   
  The kernel name.
- `system.nodename` (string)   
  The network node hostname.
- `system.kernel_release` (string)   
  The kernel release.
- `system.kernel_version` (string)   
  The kernel version.
- `system.properties` (string)   
  The processor type (non-portable).
- `system.operating_system` (string)   
  The operating system.

## Todo

There are more properties exposed by `uname` such as the machine hardware name
and the hardware platform. Those properties shall be exposed.

We shall explain what "non-portable" means.

## Example

```js
{os} = nikita.system.info.os()
console.info('Architecture:', info.arch)
console.info('Distribution:', info.distribution)
console.info('Version:', info.version)
console.info('Linux version:', info.linux_version)
```

## Handler

    handler = ({options}, callback) ->
      # TODO enrich those information with the output of
      # @execute  """
      #     . /etc/lsb-release
      #     echo "$DISTRIB_ID,$DISTRIB_RELEASE"
      #   """
      # @execute  """
      #   cat /etc/redhat-release
      #   """
      {stdout} = await @execute
        command: utils.os.command
      [arch, distribution, version, linux_version] = stdout.split '|'
      os:
        arch: arch
        distribution: distribution
        version: if version.length then version else undefined # eg Arch Linux
        linux_version: linux_version

## Exports

    module.exports =
      handler: handler
      metadata:
        shy: true

## Dependencies

    utils = require '../utils'
