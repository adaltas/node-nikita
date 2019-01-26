
registry = require '@nikita/core/lib/registry'

registry.register
  file:
    types:
      ceph_conf: '@nikita/filetypes/src/ceph_conf'
      locale_gen: '@nikita/filetypes/src/locale_gen'
      pacman_conf: '@nikita/filetypes/src/pacman_conf'
      ssh_authorized_keys: '@nikita/filetypes/src/ssh_authorized_keys'
      yum_repo: '@nikita/filetypes/src/yum_repo'

registry.deprecate ['file', 'type', 'etc_group', 'read'], '@nikita/core/lib/system/group/read'
registry.deprecate ['file', 'type', 'etc_passwd', 'read'], '@nikita/core/lib/system/user/read'
