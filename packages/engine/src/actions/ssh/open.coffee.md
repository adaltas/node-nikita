
# `nikita.ssh.open`

Initialize an SSH connection.

## Exemples

Once an SSH connection is establish, it is possible to retrieve the connection
by calling the `ssh` action. If no ssh connection is available, it will
simply return null.

```
require('nikita')
.ssh.open({
  host: 'localhost',
  user: 'my_account',
  password: 'my_secret'
})
.call(function(){
  assert(!!@ssh(), true)
})
.system.execute({
  header: 'Print remote hostname',
  cmd: 'hostname'
})
.ssh.close()
```

Set the `ssh` option to `null` or `false` to disabled SSH and force an action to be executed 
locally:

```js
require('nikita')
.ssh.open({
  host: 'localhost',
  user: 'my_account',
  password: 'my_secret'
})
.call({ssh: false}, function(){
  assert(@ssh(options.ssh), null)
})
.system.execute({
  ssh: false
  header: 'Print local hostname',
  cmd: 'hostname'
})
.ssh.close()
```

It is possible to group all the options inside the `ssh` property. This is
provided for conveniency and is often used to pass `ssh` information when
initializing the session.

```js
require('nikita')({
  ssh: {
    host: 'localhost',
    user: 'my_account',
    password: 'my_secret'
  }
})
.ssh.open()
.call(function(options){
  assert(!!@ssh(), true)
})
.ssh.close()
```

## Events

    on_action = ({options, state}) ->
      # Merge SSH config namespace
      if options.ssh and not ssh.is options.ssh
        options[k] ?= v for k, v of options.ssh or {}
        delete options.ssh
      # Define host from ip
      if options.ip and not options.host
        options.host = options.ip
      # Default root properties
      options.root ?= {}
      if options.root.ip and not options.root.host
        options.root.host = options.root.ip
      options.root.host ?= options.host
      options.root.port ?= options.port

## Schema


Options are transfered as is to the ssh2 module to create a new SSH connection.
Only will they be converted from snake case to came case. It is also possible to
pass all the options through the `ssh` property.

    schema =
      type: 'object'
      properties:
        'host':
          type: 'string'
          # oneOf: [{format: 'ipv4'}, {format: 'hostname'}]
          default: '127.0.0.1'
          description: """
          Hostname or IP address of the remove server.
          """
        'ip':
          type: 'string'
          description: """
          IP address of the remove server, used if "host" option isn't already
          defined.
          """
        'password':
          type: 'string'
          description: """
          Password of the user used to authenticate and create the SSH
          connection.
          """
        'port':
          type: 'integer'
          default: 22
          description: """
          Port of the remove server.
          """
        'private_key':
          type: 'string'
          description: """
          Content of the private key used to anthenticate the user and create
          the SSH connection. It is only used if `password` is not provided.
          """
        'private_key_path':
          type: 'string'
          default: '~/.ssh/id_rsa'
          description: """
          Local file location of the private key used to anthenticate the user and
          create the SSH connection. It is only used if `password` and
          `private_key` are not provided.
          """
        'root':
          $ref: 'module://@nikitajs/engine/src/actions/ssh/root'
          description: """
          Options passed to `nikita.ssh.root` to enable password-less root login.
          """
        'ssh':
          # instanceof: 'Object'
          default: false
          description: """
          Append the content to the target file. If target does not exist, the
          file will be created.
          """
        'username':
          type: 'string'
          default: 'root'
          description: """
          Username of the user used to anthenticate and create the SSH
          connection.
          """

## Handler

    handler = ({options, parent: {state}}) ->
      # @log message: "Entering ssh.open", level: 'DEBUG', module: 'nikita/lib/ssh/open'
      # No need to connect if ssh is a connection
      if ssh.is options.ssh
        if not state['nikita:ssh:connection']
          state['nikita:ssh:connection'] = options.ssh
          return status: true, ssh: options.ssh
        else if ssh.compare state['nikita:ssh:connection'], options.ssh
          return status: false, ssh: undefined
        else
          throw Error 'SSH Connection Already Set: call `ssh.close` before attempting to associate a new connection with `ssh.open`.'
      # Read private key if option is a path
      unless options.private_key or options.password
        @log message: "Read Private Key from: #{options.private_key_path}", level: 'DEBUG', module: 'nikita/lib/ssh/open'
        location = await tilde.normalize options.private_key_path
        try
          data = await fs.readFile location, 'ascii'
          options.private_key = data
        catch err
          throw Error "Private key doesnt exists: #{JSON.stringify location}" if err.code is 'ENOENT'
          throw err
      # Establish connection
      try
        @log message: "Read Private Key: #{JSON.stringify options.private_key_path}", level: 'DEBUG', module: 'nikita/lib/ssh/open'
        conn = await connect options
        state['nikita:ssh:connection'] = conn
        @log message: "Connection is established", level: 'INFO', module: 'nikita/lib/ssh/open'
        return ssh: conn
      catch err
        @log message: "Connection failed", level: 'WARN', module: 'nikita/lib/ssh/open'
      # Enable root access
      if options.root.username
        @log message: "Bootstrap Root Access", level: 'INFO', module: 'nikita/lib/ssh/open'
        @ssh.root options.root
      @log message: "Establish Connection: attempt after enabling root access", level: 'DEBUG', module: 'nikita/lib/ssh/open'
      @call retry: 3, ->
        conn = await connect options
        state['nikita:ssh:connection'] = conn
        ssh: conn

## Export

    module.exports =
    handler: handler
    on_action: on_action
    schema: schema
    
## Dependencies

    fs = require('fs').promises
    tilde = require '../../utils/tilde'
    ssh = require '../../utils/ssh'
    connect = require 'ssh2-connect'
