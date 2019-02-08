
nikita = require '@nikitajs/core'
{tags, ssh, scratch, lxd} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.lxd

describe 'lxd.network.delete', ->
  they 'Delete a network', (ssh) ->
