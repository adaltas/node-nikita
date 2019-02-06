nikita = require '@nikitajs/core'
{tags, ssh, scratch, lxd} = require './test'
they = require('ssh2-they').configure(ssh)

return unless tags.lxd_stop

describe 'lxd.stop' ->

  they 'Stop a container'
