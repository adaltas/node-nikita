
# `mecano.system.discover(options, [callback])`

Discover the OS.
For now it only supports Centos/Redhat OS in version 6 or 7, ubuntu.
Store properties in the mecano store object.

## Options

*   `strict` (boolean)   
    Throw an error if the OS is not supported. false by default.   
*   `cache`   
    Disable cache. false by default   

## Callback parameters

*   `err`   
    Error object if any.   
*   `status`   
    Indicate a change in service such as a change in installation, update, 
    start/stop or startup registration.   
*   `info`   
    List of info about system   


## Source Code

    module.exports = (options, callback) ->
      detected = false
      os = {}
      os.type = null
      os.release = null
      options.strict ?= false
      options.shy ?= true
      options.cache ?= true
      @system.execute
        cmd: 'cat /etc/system-release'
        if_exec: "cat /etc/system-release | egrep '(Red\\sHat)|(CentOS)'"
        unless: options.store['mecano:system:type']?
        shy: options.shy
      , (err, status, stdout, stderr) ->
        throw err if err
        if stdout
          [line] = string.lines stdout
          #might only redhat for centos/redhat
          if /CentOS/.test line
            os.type = 'centos'
            splits = line.split ' '
            os.release = splits[splits.indexOf('release')+1]
          if /Red\sHat/.test line
            os.type = 'redhat'
            splits = line.split ' '
            os.release = splits[splits.indexOf('release')+1]
          if options.cache
            options.store['mecano:system:type'] = os.type
            options.store['mecano:system:release'] = os.release
      @system.execute
        cmd: """
          . /etc/lsb-release
          echo "$DISTRIB_ID,$DISTRIB_RELEASE"
        """
        if_exec: "cat /etc/lsb-release | egrep 'Ubuntu'"
        unless: -> options.store['mecano:system:type']?
        shy: options.shy
      , (err, status, stdout, stderr) ->
        throw err if err
        if stdout
          [distrib_id, distrib_release] = stdout.trim().split ','
          #backward compatibilty remove 'mecano:system:type'
          os.type = distrib_id.toLowerCase()
          os.release = distrib_release
          if options.cache
            options.store['mecano:system:type'] = os.type
            options.store['mecano:system:release'] = os.release
          return callback Error 'Os not supported' unless (distrib_id in ['Ubuntu']) or options.strict
      @then (err, status) ->
        if options.cache
          os.type ?= options.store['mecano:system:type']
          os.release ?= options.store['mecano:system:release']
        err = Error 'OS not discovered' unless os.type or options.strict or err
        callback err, status, os

## Dependencies

    string = require '../misc/string'
