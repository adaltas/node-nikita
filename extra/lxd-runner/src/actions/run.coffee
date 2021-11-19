
module.exports = ({config}) ->
  @call '@nikitajs/lxd-runner/lib/actions/start', config
  @call '@nikitajs/lxd-runner/lib/actions/test', config
  @call '@nikitajs/lxd-runner/lib/actions/stop', config
