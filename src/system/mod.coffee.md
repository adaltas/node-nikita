
# `nikita.system.mod`

Load a kernel module. By default, unless the `persist` options is "false",
module are loaded on reboot by writing the file "/etc/modules-load.d/{name}.conf".

## Options

*   `name` (string)
    Name of the module.
*   `load` (booleaan)   
    Load the module, default is "true".
*   `persist` (booleaan)   
    Load the module on startup, default is "true".
*   `target` (string)   
    Path of the file to write the module, relative to "/etc/modules-load.d"
    unless absolute, default to "/etc/modules-load.d/{options.name}.conf".

## Examples

Activate the module "vboxpci" in the file "/etc/modules-load.d/vboxpci.conf":

```
require('nikita').system.mod({
  name: 'vboxpci'
});
```

Activate the module "vboxpci" in the file "/etc/modules-load.d/my_modules.conf":

```
require('nikita').system.mod({
  target: 'my_modules.conf',
  name: 'vboxpci'
});
```

    module.exports = (options) ->
      options.name = options.argument if options.argument?
      options.target ?= "#{options.name}.conf"
      options.target = path.resolve '/etc/modules-load.d', options.target
      options.load ?= true
      options.persist ?= true
      throw Error "Required Option: name" unless options.name
      @system.execute
        if: options.load
        cmd: """
        lsmod | grep #{options.name} && exit 3
        sudo modprobe #{options.name}
        """
        code_skipped: 3
      @file
        if: options.persist
        target: options.target
        match: ///^#{quote options.name}$///m
        replace: options.name
        append: true
        eof: true

## Dependencies

    path = require 'path'
    quote = require 'regexp-quote'
