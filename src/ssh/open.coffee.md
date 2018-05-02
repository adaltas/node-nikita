
# `nikita.ssh.open(options, [callback])`

Initialize an SSH connection.

## Options

Takes the same options as the ssh2 module in an underscore form.

* `cmd` (string)   
  Command used to become the root user on the remote server, default to "su -".   
* `private_key` (string)   
  Private key for Ryba, optional, default to the value defined by
  "bootstrap.private_key_location".   
* `private_key_path` (string)   
  Path where to read the private key for Ryba, default to "~/.ssh/id_rsa".   
* `public_key` (string)   
  Public key associated with the private key.   
* `password` (string)   
  Password of the user with super user permissions, required if current user 
  running masson doesnt yet have remote access as root.   
* `username` (string)   
  Username of the user with super user permissions, required if current user 
  running masson doesnt yet have remote access as root.  
* `host` (string)   
  Hostname or IP address of the remove server.   
* `ip` (string)   
  IP address of the remove server, used if "host" option isn't defined.   
* `host` (string)   
  Port of the remove server, default to 22.   
* `root` (object)    
  Options passed to `nikita.ssh.root` to enable password-less root login.   

## Source code

    module.exports = handler: (options) ->
      options.log message: "Entering ssh.open", level: 'DEBUG', module: 'nikita/lib/ssh/open'
      # SSH options namespace
      # options.ssh ?= {}
      options[k] ?= v for k, v of options.ssh or {}
      options.username ?= 'root'
      options.host ?= options.ip
      options.port ?= 22
      options.private_key ?= null
      options.private_key_path ?= '~/.ssh/id_rsa'
      # options.public_key ?= []
      # options.public_key = [options.public_key] if typeof options.public_key is 'string'
      options.root ?= {}
      options.root.host ?= options.ip or options.host
      options.root.port ?= options.port
      # Check status
      return if (
        @store['nikita:ssh:connection']?.config and
        @store['nikita:ssh:connection'].config.host is options.host and
        @store['nikita:ssh:connection'].config.port is options.port and
        @store['nikita:ssh:connection'].config.username is options.username
      )
      # Read private key if option is a path
      @call unless: options.private_key, (_, callback) ->
        options.log message: "Read Private Key from: #{options.private_key_path}", level: 'DEBUG', module: 'nikita/lib/ssh/open'
        misc.path.normalize options.private_key_path, (location) =>
          fs.readFile location, 'ascii', (err, content) =>
            return callback Error "Private key doesnt exists: #{JSON.stringify location}" if err and err.code is 'ENOENT'
            return callback err if err
            options.private_key = content
            callback()
      # Establish connection
      @call relax: true, (_, callback) ->
        options.log message: "Read Private Key: #{JSON.stringify options.private_key_path}", level: 'DEBUG', module: 'nikita/lib/ssh/open'
        connect options, (err, ssh) =>
          options.log unless err
          then message: "Connection is established", level: 'INFO', module: 'nikita/lib/ssh/open'
          else message: "Connection failed", level: 'WARN', module: 'nikita/lib/ssh/open'
          @store['nikita:ssh:connection'] = ssh unless err
          callback err, !!ssh
      , (err, status) ->
        @end() unless err
      # Enable root access
      @call if: options.root.username, ->
        options.log message: "Bootstrap Root Access", level: 'INFO', module: 'nikita/lib/ssh/open'
        console.log 'Deprecated Options: public_key' if options.public_key
        # @ssh.root public_key: options.public_key, options.root
        @ssh.root options.root
      @call retry: 3, (_, callback) ->
        options.log message: "Establish Connection: attempt after enabling root access", level: 'DEBUG', module: 'nikita/lib/ssh/open'
        connect options, (err, ssh) =>
          @store['nikita:ssh:connection'] = ssh unless err
          callback err

## Dependencies

    fs = require 'fs'
    misc = require '../misc'
    connect = require 'ssh2-connect'
