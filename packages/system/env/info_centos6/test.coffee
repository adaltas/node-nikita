
export default
  tags:
    system_info_disks: false
    system_info_os: true
  expect:
    os:
      arch: 'x86_64'
      distribution: 'centos'
      # linux_version: /5\.10\.\d+/
      version: '6.10'
  config: [
    label: 'remote'
    ssh:
      host: 'target', username: 'nikita',
      password: 'secret'
  ]
