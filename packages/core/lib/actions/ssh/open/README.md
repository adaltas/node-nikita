
# `nikita.ssh.open`

Initialize an SSH connection. Every following sibling actions use the
connection until it is closed by an `nikita.ssh.close` action.

## Examples

Once an SSH connection is establish, it is possible to retrieve the connection
by calling the `ssh` action. If no ssh connection is available, it will
simply return null.

```js
nikita
.ssh.open({
  host: 'localhost',
  user: 'my_account',
  password: 'my_secret'
})
.call(function(){
  assert(!!@ssh(), true)
})
.execute({
  metadata: {
    header: 'Print remote hostname'
  },
  command: 'hostname'
})
.ssh.close()
```

Set the `ssh` option to `null` or `false` to disabled SSH and force an action to be executed 
locally:

```js
nikita
.ssh.open({
  host: 'localhost',
  user: 'my_account',
  password: 'my_secret'
})
.call({ssh: false}, function(){
  assert(@ssh(config.ssh), null)
})
.execute({
  ssh: false,
  metadata: {
    header: 'Print local hostname'
  },
  command: 'hostname'
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

## Schema definitions

Configuration propeties are transfered as is to the ssh2 module to create a new SSH connection.
Only will they be converted from snake case to came case. It is also possible to
pass all the properties through the `ssh` property.
