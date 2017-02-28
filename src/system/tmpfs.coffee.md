
# `mecano.system.tmpfs(options, callback)`

Mount a direcoty with tmpfs.d as a [tmpfs](https://www.freedesktop.org/software/systemd/man/tmpfiles.d.html) configuration file.

## Options

*  `age` (String)   
    Used to decide what files to delete when cleaning   
*  `argument` (String)
    the destination path of the symlink if type is `L`
*   `backup`   
    Create a backup, append a provided string to the filename extension or a
    timestamp if value is not a string.   
*   `mount`
    The mount point dir to create on system startup.   
*   `name`
    The file name. can not be used with target. If only options.name is set, it
    writes the content to default configuration directory and creates the file 
    as '`name`.conf'   
*   `target`   
    File path where to write content to. Defined to /etc/tmpfs.d/{options.uid}.conf
    if uid is defined or /etc/tmpfs.d/default.conf.   
*   `gid`   
    File group name or group id.   
*   `Perm`   (String)
    target mount path mode in string format like `'0644'`.   
*   `merge` (boolean)
     Overrides properties if already exits.
*   `uid`   
    File user name or user id.   

## Callback parameters

*   `err`   
    Error object if any.   
*   `modified`   
    Number of written actions with modifications.   

# Example
All parameters can be omitted except type. mecano.tmpfs will ommit by replacing 
the undefined value as '-', which does apply the os default behavior.

Setting uid/gid to '-', make the os creating the target owned by root:root. 
    
## Source Code

    module.exports = (options) ->
      options.log message: "Entering tmpfs action", level: 'DEBUG', module: 'mecano/tmpfs/index'
      throw Error 'Missing Mount Point' unless options.mount?
      # for now only support directory type path option
      options.merge ?= true
      options.backup ?= true
      options.perm ?= '0644'
      options.content  = {}
      options.content[options.mount] = {}
      options.content[options.mount][key] = options[key] for key in ['mount','perm','uid','gid','age','argu']
      options.content[options.mount]['type'] = 'd'
      if options.uid?
        options.name ?= options.uid unless /^[0-9]+/.exec options.uid
      options.os ?= {}
      @system.discover (err, status, os) -> 
        options.os.type ?= os.type
        options.os.release ?= os.release
        available = (options.os.type in ['redhat','centos']) and (/^7./.test options.os.release)
        throw Error 'tempfs not available on your OS' unless available
        options.log message: "discovering tmpfs file target", level: 'DEBUG', module: 'mecano/tmpfs/index'
        options.target ?=  if options.name? then "/etc/tmpfiles.d/#{options.name}.conf" else '/etc/tmpfiles.d/default.conf'
        options.log message: "target set to #{options.target}", level: 'DEBUG', module: 'mecano/tmpfs/index'
      @call
        shy: true
        if: options.merge
        handler: (_, callback) ->
          options.log message: "opening target file for merge", level: 'DEBUG', module: 'mecano/tmpfs/index'
          fs.readFile options.ssh, options.target, 'utf8', (err, data) ->
            if err
              return callback null, false if err.code is 'ENOENT'
              return callback err if err
            else
              source = misc.tmpfs.parse data
              options.content = merge {}, source, options.content
              options.log message: "content has been merged", level: 'DEBUG', module: 'mecano/tmpfs/index'
              callback null, false
      @call ->
        @file options, content: misc.tmpfs.stringify(options.content), merge: false, target: options.target
        @call
          if: -> @status -1
          handler: ->
            options.log message: "re-creating #{options.mount} tmpfs file", level: 'INFO', module: 'mecano/tmpfs/index'
            @system.execute
              cmd: "systemd-tmpfiles --remove #{options.target}"
            @system.execute
              cmd: "systemd-tmpfiles --create #{options.target}"

## Dependencies

    fs = require 'ssh2-fs'
    path = require 'path'
    uid_gid = require '../misc/uid_gid'
    misc = require '../misc'
    {merge} = require '../misc'

[conf-tmpfs]: https://www.freedesktop.org/software/systemd/man/tmpfiles.d.html
