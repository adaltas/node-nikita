
# `nikita.fs.writeFile(options, callback)`

Options include

* `content` (string|buffer)   
  Content to write.
* `target` (string)   
  Final destination path.
* `target_tmp` (string)   
  Temporary file for upload before moving to final destination path.

## Source Code

    module.exports = status: false, handler: (options) ->
      options.log message: "Entering fs.writeFile", level: 'DEBUG', module: 'nikita/lib/fs/writeFile'
      ssh = @ssh options.ssh
      # Normalize options
      options.target = options.argument if options.argument?
      throw Error "Required Option: the \"target\" option is mandatory" unless options.target
      throw Error "Required Option: the \"content\" option is mandatory" unless options.content?
      options.flags ?= 'w' # Note, Node.js docs version 8 & 9 mention "flag" and not "flags"
      options.target_tmp ?= "/tmp/nikita_#{string.hash options.target}" if options.sudo or options.flags[0] is 'a'
      options.mode ?= 0o644 # Node.js default to 0o666
      @call if: options.flags[0] is 'a', ->
        @system.execute
          if: options.flags[0] is 'a'
          cmd: """
          [ ! -f '#{options.target}' ] && exit
          cp '#{options.target}' '#{options.target_tmp}'
          """
      , (err, status) ->
        options.log unless err
        then message: "Append prepared by placing original file in temporary path", level: 'INFO', module: 'nikita/lib/fs/write'
        else message: "Failed to place original file in temporary path", level: 'ERROR', module: 'nikita/lib/fs/writeFile'
      @call (_, callback) ->
        options.log message: 'Writting file', level: 'DEBUG', module: 'nikita/lib/fs/writeFile'
        fs.writeFile ssh, options.target_tmp or options.target, options.content, flags: options.flags, mode: options.mode, (err) ->
          options.log unless err
          then message: "File uploaded at #{JSON.stringify options.target_tmp or options.target}", level: 'INFO', module: 'nikita/lib/fs/writeFile'
          else message: "Fail to upload file at #{JSON.stringify options.target_tmp or options.target}", level: 'ERROR', module: 'nikita/lib/fs/writeFile'
          callback err
      @system.execute
        if: options.target_tmp
        cmd: """
        mv '#{options.target_tmp}' '#{options.target}'
        """
        sudo: options.sudo
        bash: options.bash
        arch_chroot: options.arch_chroot
        

## Dependencies

    fs = require 'ssh2-fs'
    string = require '../misc/string'
