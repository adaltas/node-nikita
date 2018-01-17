
# `nikita.fs.readFile(options, callback)`

## Source Code

    module.exports = status: false, handler: (options, callback) ->
      options.log message: "Entering fs.readFile", level: 'DEBUG', module: 'nikita/lib/fs/readFile'
      ssh = @ssh options.ssh
      @system.execute
        cmd: """
        [ ! -e '#{options.target}' ] && exit 2
        [ -d '#{options.target}' ] && exit 3
        cat #{options.target}
        """
        sudo: options.sudo
        bash: options.bash
        arch_chroot: options.arch_chroot
      , (err, status, stdout, stderr) ->
        if err?.code is 2
          err = Error "ENOENT: no such file or directory, open '#{options.target}'"
          err.errno = -2
          err.code = 'ENOENT'
          err.syscall = 'open'
          err.path = options.target
        if err?.code is 3
          err = Error 'EISDIR: illegal operation on a directory, read'
          err.errno = -21
          err.code = 'EISDIR'
          err.syscall = 'read'
        unless options.encoding
          stdout = new Buffer stdout, 'utf8'
        callback err, stdout
