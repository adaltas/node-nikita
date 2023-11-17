
# `nikita.system.tmpfs`

Mount a directory with tmpfs.d as a [tmpfs](https://www.freedesktop.org/software/systemd/man/tmpfiles.d.html) configuration file.

## Callback parameters

* `$status`   
  Wheter the directory was mounted or already mounted.

# Example

All parameters can be omitted except type. nikita.tmpfs will ommit by replacing 
the undefined value as '-', which does apply the os default behavior.

Setting uid/gid to '-', make the os creating the target owned by root:root. 
