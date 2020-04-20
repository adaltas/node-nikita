
# `nikita.tools.mod`

Load a kernel module.

## Options

*   `name` (string)
    Name of the module.

## Example

require('nikita').system.mod({
  name: 'vboxpci'
})

    module.exports = ({options}) ->
      options.name = options.argument if options.argument?
      throw Error "Required Option: name" unless options.name
      @system.execute
        cmd: """
        lsmod | grep #{options.name} && exit 3
        sudo modprobe #{options.name}
        """
        code_skipped: 3
