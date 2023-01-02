
module.exports = ({config, ...args}) ->
  { config } = await @lxc.state
    $header: 'Container state'
    container: "#{config.container}"
  process.stdout.write JSON.stringify config, null, 2
  
