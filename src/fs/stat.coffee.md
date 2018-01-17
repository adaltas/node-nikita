
# `nikita.fs.stat(options, callback)`

Options include:

* `dereference` (boolean)   
  Follow links, similar to `lstat`, default is "true".

## Source Code

    module.exports = status: false, handler: (options, callback) ->
      options.log message: "Entering fs.stat", level: 'DEBUG', module: 'nikita/lib/fs/stat'
      options.dereference ?= true
      dereference = if options.dereference then '-L' else ''
      throw Error "Required Option: the \"target\" option is mandatory" unless options.target
      @system.execute
        cmd: """
        [ ! -e #{options.target} ] && exit 3
        stat #{dereference} -c '%f|%u|%g|%s|%X|%Y' #{options.target}
        """
        sudo: options.sudo
        bash: options.bash
        arch_chroot: options.arch_chroot
      , (err, status, stdout, stderr) ->
        if err?.code is 3
          err = Error "Missing File: no file exists for target #{JSON.stringify options.target}"
          err.code = 'ENOENT'
          return callback err
        return callback err if err
        [rawmodehex, uid, gid, size, atime, mtime] = stdout.trim().split '|'
        stats = new Stats
          mode: parseInt '0x' + rawmodehex, 16
          uid: parseInt uid, 10
          gid: parseInt gid, 10
          size: parseInt size, 8
          atime: parseInt atime, 8 # File Access Time
          mtime: parseInt mtime, 8 # File Modify Time
        callback null, stats

    Stats = (initial) ->
      @mode = initial && initial.mode
      @uid = initial && initial.uid
      @gid = initial && initial.gid
      @size = initial && initial.size
      @atime = initial && initial.atime
      @mtime = initial && initial.mtime
    Stats.prototype._checkModeProperty = (property) ->
      (this.mode & constants.S_IFMT) is property
    Stats.prototype.isDirectory = ->
      @_checkModeProperty constants.S_IFDIR
    Stats.prototype.isFile = ->
      @_checkModeProperty constants.S_IFREG
    Stats.prototype.isBlockDevice = ->
      @_checkModeProperty constants.S_IFBLK
    Stats.prototype.isCharacterDevice = ->
      @_checkModeProperty constants.S_IFCHR
    Stats.prototype.isSymbolicLink = ->
      @_checkModeProperty constants.S_IFLNK
    Stats.prototype.isFIFO = ->
      @_checkModeProperty constants.S_IFIFO
    Stats.prototype.isSocket = ->
      @_checkModeProperty constants.S_IFSOCK

## Dependencies

    constants = require('fs').constants
