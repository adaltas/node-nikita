
# `nikita.service.discover`

Discover the operating system [init loader](https://en.wikipedia.org/wiki/Init).

The action return a `loader` property which value either equals `service` for [SysVinit](https://en.wikipedia.org/wiki/Init#SysV-style) systems, `systemd` for [systemd](https://en.wikipedia.org/wiki/Systemd) systems or `undefined`.

## Output
 
* `$status`   
  Indicate a change in service such as a change in installation, update, 
  start/stop or startup registration.
* `loader`   
  the init loader name.
