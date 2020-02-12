
# `nikita.system.mod`

Load a kernel module. By default, unless the `persist` options is "false",
module are loaded on reboot by writing the file "/etc/modules-load.d/{name}.conf".

## Options

*   `modules` (object|string)   
    Names of the modules.
*   `names` (object|string)   
    Deprecated, see `modules`.
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
require('nikita')
.system.mod({
  name: 'vboxpci'
});
```

Activate the module "vboxpci" in the file "/etc/modules-load.d/my_modules.conf":

```
require('nikita')
.system.mod({
  target: 'my_modules.conf',
  name: 'vboxpci'
});
```

## Options

    on_options = ({options}) ->
      if options.name
        console.warn 'Module system.mod: options `name` is deprecated in favor of `modules`'
        options.modules = options.name
        delete options.name
      if options.name and typeof options.name is 'string'
        options.name = [options.name]: true

## Handler

    handler = ({metadata, options}) ->
      options.modules = metadata.argument if metadata.argument?
      options.target ?= "#{options.modules}.conf"
      options.target = path.resolve '/etc/modules-load.d', options.target
      options.load ?= true
      options.persist ?= true
      throw Error "Required Option: modules" unless options.modules
      modules = for module, active of options.modules then module if active
      @system.execute
        if: options.load
        cmd: """
        lsmod | grep #{options.modules} && exit 3
        sudo modprobe #{modules.join ' '}
        """
        code_skipped: 3
      @file
        if: options.persist
        target: options.target
        match: ///^#{quote options.modules}$///m
        replace: options.modules
        append: true
        eof: true

## Exports

    module.exports =
      on_options: on_options
      handler: handler

## Dependencies

    path = require 'path'
    quote = require 'regexp-quote'
