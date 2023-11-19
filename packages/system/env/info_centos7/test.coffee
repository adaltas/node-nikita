
export default
  tags:
    system_info_disks: true
    system_info_os: true
  expect:
    os:
      arch: /x86_64|aarch64/
      distribution: 'centos'
      # linux_version: /5\.10\.\d+/
      version: /7\.9\.\d+/
  config: [
    label: 'remote'
    ssh:
      host: 'target'
      username: 'nikita'
      password: 'secret'
  ]
