
# SSH keygen

Generates keys for use by SSH protocol version 2.

## Options

* `bits` (string|number, options, 4096)   
  Specifies the number of bits in the key to create.
* `comment` (string, optional)   
  Comment such as a name or email.
* `passphrase` (string, optional, "")
  Key passphrase, empty string for no passphrase.
* `target` (string, required)   
  Path of the generated private key.
* `type` (string, optional, "rsa")   
  Type of key to create.

## Exemple

```
require('nikita')
.tools.ssh.keygen({
  bits: 2048,
  comment: 'my@email.com'
  target: './id_rsa'
})

## Source code

    module.exports = ({options}) ->
      options.bits ?= 4096
      options.type ?= 'rsa'
      options.passphrase ?= ''
      # Validation
      throw Error 'Required Option: target is required' unless options.target
      @system.mkdir
        target: "#{path.dirname options.target}"
      @system.execute
        unless_exists: "#{options.target}"
        cmd: [
          'ssh-keygen'
          "-q" # Silence
          "-t #{options.type}"
          "-b #{options.bits}"
          "-C '#{options.comment.replace '\'', '\\\''}'" if options.comment
          "-N '#{options.passphrase.replace '\'', '\\\''}'"
          "-f #{options.target}"
        ].join ' '

## Dependencies

    path = require 'path'
