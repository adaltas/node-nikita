
# `nikita.system.tmpfs(options, callback)`

Mount a directory with tmpfs.d as a [tmpfs](https://www.freedesktop.org/software/systemd/man/tmpfiles.d.html) configuration file.

## Options

* `age` (string)   
  Used to decide what files to delete when cleaning.
* `argument` (string)   
  the destination path of the symlink if type is `L`.
* `backup` (string|boolean)   
  Create a backup, append a provided string to the filename extension or a
  timestamp if value is not a string, only apply if the target file exists and
  is modified.
* `mount` (string)   
  The mount point dir to create on system startup.
* `name` (string)   
  The file name, can not be used with target. If only options.name is set, it
  writes the content to default configuration directory and creates the file 
  as '`name`.conf'.
* `target` (string)   
  File path where to write content to. Defined to /etc/tmpfiles.d/{options.uid}.conf
  if uid is defined or /etc/tmpfiles.d/default.conf.
* `gid` (string|integer)   
  File group name or group id.
* `Perm` (string)   
  target mount path mode in string format like `'0644'`.
* `merge` (boolean)   
   Overrides properties if already exits.
* `uid` (string|integer)   
  File user name or user id.

## Callback parameters

* `err`   
  Error object if any.
* `status`   
  Wheter the directory was mounted or already mounted.

# Example

All parameters can be omitted except type. nikita.tmpfs will ommit by replacing 
the undefined value as '-', which does apply the os default behavior.

Setting uid/gid to '-', make the os creating the target owned by root:root. 
    
## Source Code

    module.exports = (options) ->
      @log message: "Entering tmpfs action", level: 'DEBUG', module: 'nikita/tmpfs/index'
      # SSH connection
      ssh = @ssh options.ssh
      # Options
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
      options.target ?=  if options.name? then "/etc/tmpfiles.d/#{options.name}.conf" else '/etc/tmpfiles.d/default.conf'
      @log message: "target set to #{options.target}", level: 'DEBUG', module: 'nikita/tmpfs/index'
      @call
        shy: true
        if: options.merge
      , (_, callback) ->
          @log message: "opening target file for merge", level: 'DEBUG', module: 'nikita/tmpfs/index'
          @fs.readFile ssh: options.ssh, target: options.target, encoding: 'utf8', (err, {data}) ->
            if err
              return callback null, false if err.code is 'ENOENT'
              return callback err if err
            else
              source = misc.tmpfs.parse data
              options.content = merge {}, source, options.content
              @log message: "content has been merged", level: 'DEBUG', module: 'nikita/tmpfs/index'
              callback null, false
      @call ->
        @file options, content: misc.tmpfs.stringify(options.content), merge: false, target: options.target
        @call
          if: -> @status -1
        , ->
            @log message: "re-creating #{options.mount} tmpfs file", level: 'INFO', module: 'nikita/tmpfs/index'
            @system.execute
              cmd: "systemd-tmpfiles --remove #{options.target}"
            @system.execute
              cmd: "systemd-tmpfiles --create #{options.target}"

## Dependencies

    misc = require '../misc'
    {merge} = require '../misc'

[conf-tmpfs]: https://www.freedesktop.org/software/systemd/man/tmpfiles.d.html
