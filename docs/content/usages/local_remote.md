---
title: Local and Remote (SSH)
sort: 4
---

# Local and remote (SSH) execution

Nikita is designed to run transparently either locally or remotely through SSH. The tests are themselves written to run in both modes.

The option "ssh" must be provided for the action to run remotely. This option may either be an existing SSH connection object or a configuration object.

## Implementation

Behind the scene, the [ssh2] package written by [Brian White][brian] is used to assure the SSH transport. This is a pure JavaScript package written for node.js.

To create the connection, we use the [ssh2-connect]. The package simplifies the creation of connection and also provides a few additionnal options.

## Options

If the ssh property is a configuration object, the options used to initialize the SSH connection are the one of the [ssh2] package as well as the one of the [ssh2-connect] package.

Note that the [ssh2-connect] package will automatically convert the properties from snake case to camel case.

The [ssh2] options:

*   `host` (string)   
    Hostname or IP address of the server, default is 'localhost'.

*   `port` (integer)   
    Port number of the server. Default: 22

*   `hostHash` (string)   
    'md5' or 'sha1'. The host's key is hashed using this method and passed to the hostVerifier function. Default: (none)

*   `hostVerifier` (function)   
    Function that is passed a string hex hash of the host's key for verification purposes. Return true to continue with the connection, false to reject and disconnect. Default: (none)

*   `username` (string)   
    Username for authentication. Default: (none)

*   `password` (string)   
    Password for password-based user authentication. Default: (none)

*   `agent` (string)   
    Path to ssh-agent's UNIX socket for ssh-agent-based user authentication. Windows users: set to 'pageant' for authenticating with Pageant or (actual) path to a cygwin "UNIX socket." Default: (none)

*   `privateKey` (mixed)   
    Buffer or string that contains a private key for key-based user authentication (OpenSSH format). Default: (none)

*   `passphrase` (string)   
    For an encrypted private key, this is the passphrase used to decrypt it. Default: (none)

*   `tryKeyboard` (boolean)   
    Try keyboard-interactive user authentication if primary user authentication method fails. Default: false

*   `pingInterval` (integer)   
    How often (in milliseconds) to send SSH-level keepalive packets to the server. Default: 60000

*   `readyTimeout` (integer)   
    How long (in milliseconds) to wait for the SSH handshake to complete. Default: 10000

*   `sock` (ReadableStream)   
    A ReadableStream to use for communicating with the server instead of creating and using a new TCP connection (useful for connection hopping).

*   `agentForward` (boolean)   
    Set to true to use OpenSSH agent forwarding ('auth-agent@openssh.com'). Default: false

The [ssh2-connect] options:

-   `username` (string)   
    The username used to initiate the connection, default to the current
    environment user.
-   `privateKeyPath` (string)   
    Path to the file containing the private key.   
-   `retry` (integer)
    Attempt to reconnect multiple times, default to "1".   
-   `wait` (integer)
    Time to wait in milliseconds between each retry, default to "500".  

## Passing an existing SSH connection

```js
const connect = require('ssh2-connect');
const nikita = require('nikita');
// Create an SSH connection
connect({
  host: 'localhost',
  username: 'root',
  private_key_path: '~/.ssh/id_rsa'
}, function(err, ssh){
  if(err) return process.exit(1);
  // Pass the connection to the `touch` action
  nikita
  .file.touch({
    ssh: ssh
    target: '/tmp/a_file'
  }, function(err, {status}){
    if(err) return process.exit(1);
    console.info('File written: ' + status);
    ssh.end();
  });
});
```

## Passing an SSH configuation

```js
const nikita = require('nikita');
// Pass the connection properties to the `ssh` option
nikita
.file.touch({
  ssh: {
    host: 'localhost',
    username: 'root',
    private_key_path: '~/.ssh/id_rsa'
  },
  target: '/tmp/a_file'
}, function(err, {status}){
  if(err) return process.exit(1);
  console.info('File written: ' + status);
  ssh.end();
});
```

## Root access

If root privileges are required and root access is not available because no authorised key has been set, it is possible to let Nikita deploy the public key or execute Nikita with [`sudo`](/metadata/sudo/).

The `root` option instruct the `ssh.open` action to enable root access through another user. This user must have passwordless sudo enabled.

```js
const nikita = require('nikita');
// Global activation
nikita
.ssh.open({
  host: 'localhost',
  username: 'root',
  // The private key of the targeted user
  private_key_path: './root_id_rsa',
  root: {
    username: 'vagrant',
    // The private key of the sudoer user used to bootstrap the connection
    private_key_path: require('os').homedir()+'/.vagrant.d/insecure_private_key',
    // The public key to deploy
    public_key_path: 'root_id_rsa.pub'
  }
})
.ssh.close()
```

To enable `sudo`, just enable sudo as a global option or for any action. The option will be propagated to its children.

```js
const nikita = require('nikita');
// Global activation
nikita({
  sudo: true
})
.ssh.open({
  host: 'localhost',
  username: process.env['USER'],
  private_key_path: '~/.ssh/id_rsa'
})
.system.execute({
  cmd: 'whoami'
}, function(err, {stdout}){
  assert('whoami' === 'root')
})
.ssh.close()
```

[ssh2-connect]: https://github.com/wdavidw/ssh2-connect
[ssh2]: https://github.com/mscdex/ssh2
[brian]: https://github.com/mscdex
