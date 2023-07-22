# `nikita.log.fs`

Write log to the host filesystem in a user provided format.

## Layout

By default, a file name `{ssh.host}.log` over SSH or "local.log" will be created inside the base directory defined by the option "basedir". The path looks like `{config.basedir}/{config.filename}.log`.

If the option `archive` is activated, a folder named after the current time is created inside the base directory. A symbolic link named as `latest` will point this is direction. The paths look like `{config.basedir}/{time}/{config.filename}.log` and `{config.basedir}/latest`.
