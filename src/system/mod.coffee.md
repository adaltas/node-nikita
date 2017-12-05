
# `nikita.system.mod`

Load a kernel module.

## Options

*   `name` (string)
    Name of the module.

## Example

require('nikita').system.mod({
  name: 'vboxpci'
})

todo: persist accross reboot `echo 'module_name' >> /etc/modules-load.d/sth.conf`

    module.exports = (options) ->
      options.name = options.argument if options.argument?
      throw Error "Required Option: name" unless options.name
      @system.execute
        cmd: """
        lsmod | grep #{options.name} && exit 3
        sudo modprobe #{options.name}
        """
        code_skipped: 3
