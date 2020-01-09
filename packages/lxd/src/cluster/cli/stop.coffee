
nikita = require 'nikita'

module.exports = ({params}) ->
  nikita
    debug: params.debug
  .system.execute
    debug: params.debug
    cwd: "#{__dirname}/../../../assets"
    cmd: '''
    vagrant halt
    '''
