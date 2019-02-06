nikita = require '@nikitajs/core'
{tags, ssh, scratch, lxc} = require './test'
they = require('ssh2-they').configure(ssh)

return unless tags.lxc_stop

describe 'lxc.stop' ->

  they 'Stop a container', (ssh)
