
# Mecano Misc Discover
Enable Mecano.service to discover the os.
For now it only supports Centos/Redhat OS in version 6 or 7.
Store properties in the mecano store object.

    module.exports =
      system: (options) ->
        @system.execute
          cmd: 'cat /etc/system-release'
          shy: true
          code_skipped: 1
        , (err, status, stdout, stderr) ->
          throw err if err
          [line] = string.lines stdout
          if /CentOS/.test line
            options.store['mecano:system:type'] ?= 'centos'
            index = line.split(' ').indexOf 'release'
            options.store['mecano:system:release'] ?= line.split(' ')[index+1]
          if /Red\sHat/.test line
            options.store['mecano:system:type'] ?= 'redhat'
            index = line.split(' ').indexOf 'release'
            options.store['mecano:system:release'] ?= line.split(' ')[index+1]
          throw Error 'Unsupported OS' unless options.store['mecano:system:type']?
      loader: (options) ->
        @system.execute
          shy: true
          cmd: """
          if which systemctl >/dev/null; then exit 1; fi ;
          if which service >/dev/null; then exit 2; fi ;
          exit 3 ;
          """
          code: [1, 2]
          unless: options.loader?
          shy: true
        , (err, status, stdout, stderr, signal) ->
          throw Error "Undetected Operating System Loader" if err?.code is 3
          throw err if err
          return unless status
          options.store ?= {}
          options.loader = switch signal
            when 1 then 'systemctl'
            when 2 then 'service'
          options.store['mecano:service:loader'] = options.loader
        

## Dependencies

    string = require '../misc/string'
