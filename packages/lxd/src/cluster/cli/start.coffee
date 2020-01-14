
nikita = require 'nikita'

key = "#{__dirname}/../../../assets/.vagrant/machines/default/virtualbox/private_key"
module.exports = ({params}) ->
  nikita
    debug: params.debug
  .system.execute
    header: 'Dependencies'
    unless_exec: 'vagrant plugin list | egrep \'^vagrant-vbguest \''
    cmd: '''
    vagrant plugin install vagrant-vbguest
    '''
  .system.execute
    cwd: "#{__dirname}/../../../assets"
    cmd: '''
    vagrant up
    '''
  .system.execute
    cmd: '''
    lxc remote add nikita 127.0.0.1:8443 --accept-certificate --password secret
    lxc remote switch nikita
    '''
  .system.execute
    cmd: '''
    lxc ls || {
      lxc remote switch local
      lxc remote remove nikita
      lxc remote add nikita --accept-certificate --password secret 127.0.0.1:8443
      lxc remote switch nikita
    }
    '''
  .call ->
    disabled: true
    cmd: """
    ssh -i #{key} -qtt -p 2222 vagrant@127.0.0.1 -- "cd /nikita && bash"\n
    """
    stdin: process.stdin
    stderr: process.stderr
    stdout: process.stdout
  .call ->
    process.stdout.write """
    ssh -i #{key} -qtt -p 2222 vagrant@127.0.0.1 -- "cd /nikita && bash"\n
    """
