
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
  assert(@ssh(config.ssh), null)
})
.system.execute({
  ssh: false
  header: 'Print local hostname',
  cmd: 'hostname'
})
.ssh.close()
```

It is possible to group all the config properties inside the `ssh` property. This is
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
.call(function({config}){
  assert(!!@ssh(), true)
})
.ssh.close()
```

## Hooks

    on_action = ({config, state}) ->
      # Merge SSH config namespace
      if config.ssh and not ssh.is config.ssh
        config[k] ?= v for k, v of config.ssh or {}
        delete config.ssh
      # Define host from ip
      if config.ip and not config.host
        config.host = config.ip
      # Default root properties
      config.root ?= {}
      if config.root.ip and not config.root.host
        config.root.host = config.root.ip
      config.root.host ?= config.host
      config.root.port ?= config.port

## Schema

Configuration propeties are transfered as is to the ssh2 module to create a new SSH connection.
Only will they be converted from snake case to came case. It is also possible to
pass all the properties through the `ssh` property.

    schema =
      type: 'object'
      properties:
        'host':
          type: 'string'
          anyOf: [{format: 'ipv4'}, {format: 'hostname'}]
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
          Local file location of the private key used to anthenticate the user
          and create the SSH connection. It is only used if `password` and
          `private_key` are not provided.
          """
        'root':
          $ref: 'module://@nikitajs/engine/src/actions/ssh/root'
          description: """
          Configuration passed to `nikita.ssh.root` to enable password-less root
          login.
          """
        'ssh':
          instanceof: 'Object'
          description: """
          Associate an existing SSH connection to the current action and its
          siblings.
          """
        'username':
          type: 'string'
          default: 'root'
          description: """
          Username of the user used to anthenticate and create the SSH
          connection.
          """

## Handler

    handler = ({config, parent: {state}}) ->
      # @log message: "Entering ssh.open", level: 'DEBUG', module: 'nikita/lib/ssh/open'
      # No need to connect if ssh is a connection
      if ssh.is config.ssh
        if not state['nikita:ssh:connection']
          state['nikita:ssh:connection'] = config.ssh
          return status: true, ssh: state['nikita:ssh:connection']
        else if ssh.compare state['nikita:ssh:connection'], config.ssh
          return status: false, ssh: state['nikita:ssh:connection']
        else
          throw error 'NIKITA_SSH_OPEN_UNMATCHING_SSH_INSTANCE', [
            'attempting to set an SSH connection'
            'while an instance is already registered with a different configuration'
            "got #{JSON.stringify object.copy config.ssh.config, ['host', 'port', 'username']}"
          ]
      # Get from cache
      if state['nikita:ssh:connection']
        # The new connection refer to the same target and the current one
        if ssh.compare state['nikita:ssh:connection'], config
          return status: false, ssh: state['nikita:ssh:connection']
        else
          throw error 'NIKITA_SSH_OPEN_UNMATCHING_SSH_CONFIG', [
            'attempting to retrieve an SSH connection'
            'with user SSH configuration not matching'
            'the current SSH connection stored in state,'
            'one possible solution is to close the current connection'
            'with `nikita.ssh.close` before attempting to open a new one'
            "got #{JSON.stringify object.copy config, ['host', 'port', 'username']}"
          ]
      # Read private key if option is a path
      unless config.private_key or config.password
        @log message: "Read Private Key from: #{config.private_key_path}", level: 'DEBUG', module: 'nikita/lib/ssh/open'
        location = await tilde.normalize config.private_key_path
        try
          data = await fs.readFile location, 'ascii'
          config.private_key = data
        catch err
          throw Error "Private key doesnt exists: #{JSON.stringify location}" if err.code is 'ENOENT'
          throw err
      # Establish connection
      try
        @log message: "Read Private Key: #{JSON.stringify config.private_key_path}", level: 'DEBUG', module: 'nikita/lib/ssh/open'
        conn = await connect config
        state['nikita:ssh:connection'] = conn
        @log message: "Connection is established", level: 'INFO', module: 'nikita/lib/ssh/open'
        return status: true, ssh: conn
      catch err
        @log message: "Connection failed", level: 'WARN', module: 'nikita/lib/ssh/open'
      # Enable root access
      if config.root.username
        @log message: "Bootstrap Root Access", level: 'INFO', module: 'nikita/lib/ssh/open'
        @ssh.root config.root
      @log message: "Establish Connection: attempt after enabling root access", level: 'DEBUG', module: 'nikita/lib/ssh/open'
      @call retry: 3, ->
        conn = await connect config
        state['nikita:ssh:connection'] = conn
        status: true, ssh: conn

## Export

    module.exports =
    handler: handler
    on_action: on_action
    schema: schema
    
## Dependencies

    fs = require('fs').promises
    error = require '../../utils/error'
    object = require '../../utils/object'
    tilde = require '../../utils/tilde'
    ssh = require '../../utils/ssh'
    connect = require 'ssh2-connect'
