
# `nikita.ssh.root(options, [callback])`

Prepare the system to receive password-less root login with SSL/TLS keys.

Prior executing this handler, a user with appropriate sudo permissions must be 
created. The script will use those credentials
to loggin and will try to become root with the "sudo" command. Use the "cmd" 
property if you must use a different command (such as "sudo su -").

Additionnally, it disables SELINUX which require a restart. The restart is 
handled by Masson and the installation procedure will continue as soon as an 
SSH connection is again available.

## Options

*   `cmd` (string | function)   
    Command used to become the root user on the remote server, for exemple 
    `su -`.   
*   `public_key` (string | Buffer)   
    Public key added to "authorized_keys" to enable the root user.   
*   `public_key_path` (string | Buffer)   
    Local path to the public key added to "authorized_keys" to enable the root 
    user.   
*   `username` (string)   
    Username of the user with sudo permissions to establish the SSH connection.   
*   `password` (string)   
    Password of the user with sudo permissions to establish the SSH connection 
    if no private key is provided.   
*   `private_key` (string)   
    Private key of the user with sudo permissions to establish the SSH 
    connection if no password is provided.   
*   `private_key_path` (string)   
    Local path to the private key of the user with sudo permissions to 
    establish the SSH connection if no password is provided.   
*   `selinux` (string | boolean)   
    Controls the state of SELinux on the system, values are "enforcing", 
    "permissive", "disabled".   

## Exemple

```js
require('nikita')
.ssh.root({
  "username": "vagrant",
  "private_key_path": "/Users/wdavidw/.vagrant.d/insecure_private_key"
  "public_key_path": "~/.ssh/id_rsa.pub"
}, function(err){
  console.log(err || "Public key updoaded for root user");
});
```

## Source code

    module.exports = handler: (options) ->
      options.log message: "Entering ssh.root", level: 'DEBUG', module: 'nikita/lib/ssh/root'
      options.host ?= options.ip
      # options.cmd ?= 'su -'
      options.username ?= null
      options.password ?= null
      options.selinux ?= false
      options.selinux = 'permissive' if options.selinux is true
      # Validation
      throw Error "Invalid option \"selinux\": #{options.selinux}" if options.selinux and options.selinux not in ['enforcing', 'permissive', 'disabled']
      rebooting = false
      # Read public key if option is a path
      @call
        if: options.public_key_path
        unless: options.public_key
      , (_, callback) ->
        misc.path.normalize options.public_key_path, (location) =>
          fs.readFile location, 'ascii', (err, content) =>
            return callback Error "Private key doesnt exists: #{JSON.stringify location}" if err and err.code is 'ENOENT'
            return callback err if err
            options.public_key = content
            callback()
      # Read private key if option is a path
      @call
        if: options.private_key_path
        unless: options.private_key
      , (_, callback) ->
        options.log message: "Read Private Key from: #{options.private_key_path}", level: 'DEBUG', module: 'nikita/lib/ssh/root'
        misc.path.normalize options.private_key_path, (location) =>
          fs.readFile location, 'ascii', (err, content) =>
            return callback Error "Private key doesnt exists: #{JSON.stringify location}" if err and err.code is 'ENOENT'
            return callback err if err
            options.private_key = content
            callback()
      @call (_, callback) ->
        options.log message: "Connecting", level: 'DEBUG', module: 'nikita/lib/ssh/root'
        connect options, (err, ssh) ->
          return callback err if err
          options.log message: "Connected", level: 'INFO', module: 'nikita/lib/ssh/root'
          cmd = []
          cmd.push """
          sed -i.back 's/.*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config;
          """
          cmd.push """
          mkdir -p /root/.ssh; chmod 700 /root/.ssh;
          echo '#{options.public_key}' >> /root/.ssh/authorized_keys;
          """ if options.public_key
          cmd.push """
          sed -i.back 's/.*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config;
          selinux="#{options.selinux or ''}";
          if [ -n "$selinux" ] && [ -f /etc/selinux/config ] && grep ^SELINUX="$selinux" /etc/selinux/config;
          then
            exit 2;
          else
            sed -i.back "s/^SELINUX=enforcing/SELINUX=$selinux/" /etc/selinux/config;
            reboot;
            exit 2;
          fi;
          """
          cmd = cmd.join '\n'
          if options.username isnt 'root'
            cmd = cmd.replace /\n/g, ' '
            if typeof options.cmd is 'function'
              cmd = options.cmd cmd
            else if typeof options.cmd is 'string'
              cmd = "#{options.cmd} #{cmd}"
            else
              options.cmd = 'sudo '
              options.cmd += "-u #{options.user} " if options.user
              options.cmd = "echo -e \"#{options.password}\\n\" | #{options.cmd} -S " if options.password
              options.cmd += "-- sh -c \"#{cmd}\""
              cmd = options.cmd
          options.log message: "Enable Root Access", level: 'DEBUG', module: 'nikita/lib/ssh/root'
          options.log message: cmd, type: 'stdin', module: 'nikita/lib/ssh/root'
          child = exec
            ssh: ssh
            cmd: cmd
          , (err) ->
            if err?.code is 2
              options.log message: "Root Access Enabled", level: 'WARN', module: 'nikita/lib/ssh/root'
              err = null
              rebooting = true
            callback err
          child.stdout.on 'data', (data) ->
            options.log message: data, type: 'stdout', module: 'nikita/lib/ssh/root'
          child.stdout.on 'end', (data) ->
            options.log message: null, type: 'stdout', module: 'nikita/lib/ssh/root'
          child.stderr.on 'data', (data) ->
            options.log message: data, type: 'stderr', module: 'nikita/lib/ssh/root'
          child.stderr.on 'end', (data) ->
            options.log message: null, type: 'stderr', module: 'nikita/lib/ssh/root'
      @call retry: true, if: rebooting, (_, callback) ->
        connect config, (err, conn) =>
          return callback err unless conn
          conn.end()
          conn.on 'error', callback
          conn.on 'end', callback

## Dependencies

    fs = require 'fs'
    util = require 'util'
    connect = require 'ssh2-connect'
    exec = require 'ssh2-exec'
    misc = require '../misc'
