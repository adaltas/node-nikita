
# `nikita.fs.createReadStream(options, callback)`

## Source Code

    module.exports = status: false, handler: (options, callback) ->
      options.log message: "Entering fs.createReadStream", level: 'DEBUG', module: 'nikita/lib/fs/createReadStream'
      ssh = @ssh options.ssh
      # Normalize options
      options.target = options.argument if options.argument?
      throw Error "Required Option: the \"target\" option is mandatory" unless options.target
      options.target_tmp ?= "/tmp/nikita_#{string.hash options.target}" if options.sudo
      content = null
      @call if: options.target_tmp, ->
        @system.execute
          sudo: options.sudo
          bash: options.bash
          arch_chroot: options.arch_chroot
          cmd: """
          [ ! -f '#{options.target}' ] && exit
          cp '#{options.target}' '#{options.target_tmp}'
          """
      , (err, status) ->
        options.log unless err
        then message: "Placing original file in temporary path before reading", level: 'INFO', module: 'nikita/lib/fs/createReadStream'
        else message: "Failed to place original file in temporary path", level: 'ERROR', module: 'nikita/lib/fs/createReadStream'
        callback err if err
      @call ->
        buffers = []
        options.log message: "Reading file #{options.target_tmp or options.target}", level: 'DEBUG', module: 'nikita/lib/fs/createReadStream'
        fs.createReadStream ssh, options.target_tmp or options.target, (err, rs) ->
          return callback err if err
          rs.on 'readable', ->
            options.on_readable rs
          rs.on 'error', callback
          rs.on 'end', callback

## Dependencies

    fs = require 'ssh2-fs'
