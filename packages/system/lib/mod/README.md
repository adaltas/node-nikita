
# `nikita.system.mod`

Load a kernel module. By default, unless the `persist` config is "false",
module are loaded on reboot by writing the file "/etc/modules-load.d/{name}.conf".

## Examples

Activate the module "vboxpci" in the file "/etc/modules-load.d/vboxpci.conf":

```
nikita.system.mod({
  modules: 'vboxpci'
})
```

Activate the module "vboxpci" in the file "/etc/modules-load.d/my_modules.conf":

```
nikita.system.mod({
  target: 'my_modules.conf',
  modules: 'vboxpci'
});
```
