
module.exports = ssh =
  compare: (ssh1, ssh2) ->
    # Between 2 configurations
    compare_config = (config1, config2) ->
      config1 and config2 and
      config1.host is config2.host and
      (config1.port or 22) is (config2.port or 22) and
      config1.username is config2.username
    # Compare
    (
      # 2 null
      not ssh1 and not ssh2 and !!ssh1 is !!ssh2
    ) or (
      # 2 SSH instances
      ssh.is(ssh1) and
      ssh.is(ssh2) and
      compare_config ssh1.config, ssh2.config
    ) or (
      # 2 SSH configurations
      not ssh.is(ssh1) and
      not ssh.is(ssh2) and
      compare_config ssh1, ssh2
    ) or (
      # SSH instance with SSH configuration
      ssh.is(ssh1) and not ssh.is(ssh2) and
      compare_config ssh1.config, ssh2
    )  or (
      # SSH instance with SSH configuration
      not ssh.is(ssh1) and ssh.is(ssh2) and
      compare_config ssh1, ssh2.config
    ) or false
  is: (ssh) ->
    return false unless ssh?._sshstream?.config?.ident?
    ssh._sshstream.config.ident is 'SSH-2.0-ssh2js0.2.0'
