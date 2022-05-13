
module.exports = ({config}) ->
  @lxc.delete
    $header: 'Container delete'
    container: "#{config.container}"
    force: config.force
