
# `nikita.ssh.root`

Prepare the system to receive password-less root login with SSL/TLS keys.

Prior executing this handler, a user with appropriate sudo permissions must be 
created. The script will use those credentials
to loggin and will try to become root with the "sudo" command. Use the "cmd" 
property if you must use a different command (such as "sudo su -").

Additionnally, it disables SELINUX which require a restart. The restart is 
handled by Masson and the installation procedure will continue as soon as an 
SSH connection is again available.

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

## Schema

    schema =
      type: 'object'
      properties:
        'cmd':
          oneOf: [{type: 'string'}, {typeof: 'function'}]
        'host':
          type: 'string'
          # oneOf: [{format: 'ipv4'}, {format: 'hostname'}]
          default: 'root'
          description: """
          Command used to become the root user on the remote server, for exemple
          `su -`.
          """
        'password':
          type: 'string'
          description: """
          Password of the user with sudo permissions to establish the SSH
          connection  if no private key is provided.
          """
        'port':
          type: 'integer'
          default: 22
          description: """
          """
        'private_key':
          type: 'string'
          description: """
          Private key of the user with sudo permissions to establish the SSH
          connection if `password` is not provided.
          """
        'private_key_path':
          type: 'string'
          description: """
          Local file location of the private key of the user with sudo
          permissions and used to establish the SSH connection if `password` and
          `private_key` are not provided.
          """
        'public_key':
          oneOf: [{type: 'string'}, {instanceof: 'Buffer'}]
          description: """
          Public key added to "authorized_keys" to enable the root user.
          """
        'public_key_path':
          type: 'string'
          description: """
          Local path to the public key added to "authorized_keys" to enable the
          root  user.
          """
        'selinux':
          oneOf: [
            {type: 'string', enum: ['disabled', 'enforcing', 'permissive']},
            {type: 'boolean'}
          ]
          default: 'permissive'
          description: """
          Username of the user with sudo permissions to establish the SSH
          connection.
          """
        'username':
          type: 'string'
          description: """
          Username of the user with sudo permissions to establish the SSH
          connection.
          """

## Handler

    handler = ({options}) ->
      @log message: "Entering ssh.root", level: 'DEBUG', module: 'nikita/lib/ssh/root'
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
      if options.public_key_path and not options.public_key
        location = await tilde.normalize options.public_key_path
        try
          options.public_key = await fs.readFile location, 'ascii'
        catch err
          throw Error "Private key doesnt exists: #{JSON.stringify location}" if err.code is 'ENOENT'
          throw err
      # Read private key if option is a path
      if options.private_key_path and not options.private_key
        @log message: "Read Private Key: #{JSON.stringify options.private_key_path}", level: 'DEBUG', module: 'nikita/lib/ssh/root'
        location = await tilde.normalize options.private_key_path
        try
          options.private_key = await fs.readFile location, 'ascii'
        catch err
          throw Error "Private key doesnt exists: #{JSON.stringify location}" if err.code is 'ENOENT'
          throw err
      await @call ->
        @log message: "Connecting", level: 'DEBUG', module: 'nikita/lib/ssh/root'
        conn = await connect options
        @log message: "Connected", level: 'INFO', module: 'nikita/lib/ssh/root'
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
          sed -i.back "s/^SELINUX=enforcing/SELINUX=$selinux/" /etc/selinux/config;
          ( reboot )&
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
        @log message: "Enable Root Access", level: 'DEBUG', module: 'nikita/lib/ssh/root'
        @log message: cmd, type: 'stdin', module: 'nikita/lib/ssh/root'
        child = exec
          ssh: conn
          cmd: cmd
        , (err) =>
          if err?.code is 2
            @log message: "Root Access Enabled", level: 'WARN', module: 'nikita/lib/ssh/root'
            err = null
            rebooting = true
          else throw err
        child.stdout.on 'data', (data) =>
          @log message: data, type: 'stdout', module: 'nikita/lib/ssh/root'
        child.stdout.on 'end', (data) =>
          @log message: null, type: 'stdout', module: 'nikita/lib/ssh/root'
        child.stderr.on 'data', (data) =>
          @log message: data, type: 'stderr', module: 'nikita/lib/ssh/root'
        child.stderr.on 'end', (data) =>
          @log message: null, type: 'stderr', module: 'nikita/lib/ssh/root'
      @call retry: true, sleep: 3000, if: rebooting, ->
        conn = connect options
        conn.end()

## Exports

    module.exports =
      handler: handler
      schema: schema

## Dependencies

    fs = require('fs').promises
    connect = require 'ssh2-connect'
    exec = require 'ssh2-exec'
    tilde = require '../../utils/tilde'
