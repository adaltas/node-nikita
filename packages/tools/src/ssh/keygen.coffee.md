
# SSH keygen

Generates keys for use by SSH protocol version 2.

## Options

* `bits` (string|number, options, 4096)   
  Specifies the number of bits in the key to create.
* `comment` (string, optional)   
  Comment such as a name or email.
* `key_format` (string, optional)   
  Specify a key format. The supported key formats are: `RFC4716` (RFC 4716/SSH2 public or
  private key), `PKCS8` (PEM PKCS8 public key) or `PEM` (PEM public key).
* `passphrase` (string, optional, "")
  Key passphrase, empty string for no passphrase.
* `target` (string, required)   
  Path of the generated private key.
* `type` (string, optional, "rsa")   
  Type of key to create.

## Force the generation of a key compatible with SSH2

For exemple in OSX Mojave, the default export format is RFC4716.

```
require('nikita')
.tools.ssh.keygen({
  bits: 2048,
  comment: 'my@email.com'
  target: './id_rsa',
  key_format: 'PEM'
})

## Source code

    module.exports = ({options}) ->
      options.bits ?= 4096
      options.type ?= 'rsa'
      options.passphrase ?= ''
      options.key_format ?= null
      throw Error "Invalid Option: key_format must be one of RFC4716, PKCS8 or PEM, got #{JSON.stringify options.key_format}" if options.key_format and options.key_format not in ['RFC4716', 'PKCS8', 'PEM']
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
          "-m #{options.key_format}" if options.key_format
          "-C '#{options.comment.replace '\'', '\\\''}'" if options.comment
          "-N '#{options.passphrase.replace '\'', '\\\''}'"
          "-f #{options.target}"
        ].join ' '

## Dependencies

    path = require 'path'
