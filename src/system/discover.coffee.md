
# `nikita.system.discover(options, [callback])`

Discover the OS.
For now it only supports Centos/Redhat OS in version 6 or 7, ubuntu.
Store properties in the nikita store object.

## Options

* `strict` (boolean)   
  Throw an error if the OS is not supported. false by default.   
* `cache`   
  Enable cache, "false" by default.   

## Callback parameters

* `err`   
  Error object if any.   
* `status`   
  True if information was fetch from system, false if retrieved from cache.   
* `info`   
  List of info about system   

## Example

```javascript
nikita.system.discover({
  ssh: ssh
}, function(err, status, info){
  console.log(err || 'Use cache: ' + status);
  console.log(err || 'System: ' + info.type);     // eg "redhat" or "centos"
  console.log(err || 'Release: ' + info.release); // eg "6" or "7"
});
```

## Source Code

    module.exports = shy: true, handler: (options, callback) ->
      detected = false
      os = {}
      os.type = null
      os.release = null
      options.strict ?= false
      options.cache ?= false
      if options.cache and options.store['nikita:system:type']
        return callback null, false, 
          type: options.store['nikita:system:type']
          release: options.store['nikita:system:release']
      @system.execute
        cmd: 'cat /etc/redhat-release'
        if_exec: "cat /etc/redhat-release | egrep '(Red\\sHat)|(CentOS)'"
        unless: options.store['nikita:system:type']?
      , (err, status, stdout, stderr) ->
        throw err if err
        return unless status
        [line] = string.lines stdout
        #might only redhat for centos/redhat
        if /^CentOS/.test line
          os.type = 'centos'
          splits = line.split ' '
          os.release = splits[splits.indexOf('release')+1]
        if /^Red\sHat/.test line
          os.type = 'redhat'
          splits = line.split ' '
          os.release = splits[splits.indexOf('release')+1]
        if /^Oracle/.test line
          os.type = 'oracle'
          splits = line.split ' '
          os.release = splits[splits.indexOf('release')+1]
        if options.cache
          options.store['nikita:system:type'] = os.type
          options.store['nikita:system:release'] = os.release
        throw Error 'OS not supported' if options.strict and os.type not in ['redhat', 'centos', 'oracle']
      @system.execute
        cmd: """
          . /etc/lsb-release
          echo "$DISTRIB_ID,$DISTRIB_RELEASE"
        """
        if_exec: "cat /etc/lsb-release | egrep 'Ubuntu'"
        unless: -> options.store['nikita:system:type']?
      , (err, status, stdout, stderr) ->
        throw err if err
        return unless status
        [distrib_id, distrib_release] = stdout.trim().split ','
        #backward compatibilty remove 'nikita:system:type'
        os.type = distrib_id.toLowerCase()
        os.release = distrib_release
        if options.cache
          options.store['nikita:system:type'] = os.type
          options.store['nikita:system:release'] = os.release
        throw Error 'OS not supported' if options.strict and os.type not in ['ubuntu']
      @next (err, status) ->
        callback err, status, os

## Dependencies

    string = require '../misc/string'
