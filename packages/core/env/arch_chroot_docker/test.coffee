
export default
  tags:
    conditions_if_os: true
    system_execute_arc_chroot: true
  conditions_if_os:
    arch: 'x86_64'
    distribution: 'arch'
    # version is a moving target
    # linux_version is automatically detected 
  config: [
    label: 'local'
  ,
    label: 'remote'
    ssh:
      host: '127.0.0.1', username: process.env.USER,
      private_key_path: '~/.ssh/id_ed25519'
  ]
