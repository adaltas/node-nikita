
module.exports = ({config}) ->
  # Note, using `lxc shell` would be nice but `cwd` doesn't seem right
  # `lxc shell --cwd /nikita/packages/$pkg` then `pwd` return `/root`
  # `lxc shell --cwd /nikita/packages/$pkg -- pkg` prints:
  #   `pwd: ignoring non-option arguments`
  #   `/nikita/packages/$pkg`
  @execute
    $header: 'Container enter'
    command: """
    lxc exec \
      --cwd #{config.cwd} \
      #{config.container} -- bash
    """
    stdio: ['inherit', 'inherit', 'inherit']
    stdin: process.stdin
    stdout: process.stdout
    stderr: process.stderr
