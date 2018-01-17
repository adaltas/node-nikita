
# `nikita.fs.rmdir(options, callback)`

Delete a directory.

* `target` (string)   
  Final destination path.

## Source Code

    module.exports = status: false, handler: (options) ->
      options.log message: "Entering fs.rmdir", level: 'DEBUG', module: 'nikita/lib/fs/rmdir'
      ssh = @ssh options.ssh
      throw Error "Required Option: the \"target\" option is mandatory" unless options.target
      @system.execute
        cmd: """
        [ ! -d '#{options.target}' ] && exit 2
        rmdir '#{options.target}'
        """
        sudo: options.sudo
        bash: options.bash
        arch_chroot: options.arch_chroot
      , (err, status) ->
        if err?.code is 2
          err = Error "ENOENT: no such file or directory, rmdir '#{options.target}'"
          err.errno = -2
          err.code = 'ENOENT'
          err.syscall = 'rmdir'
          err.path = "#{options.target}"
        options.log unless err
        then message: "Directory successfully removed", level: 'INFO', module: 'nikita/lib/fs/write'
        else message: "Fail to remove directory", level: 'ERROR', module: 'nikita/lib/fs/write'
        throw err
