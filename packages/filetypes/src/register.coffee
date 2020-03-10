
# Registration of `nikita.filetypes` actions

## Dependency

    require '@nikitajs/core/lib/register'
    {register} = require '@nikitajs/core/lib/registry'

## Action registration

    register
      file:
        types:
          ceph_conf: '@nikitajs/filetypes/src/ceph_conf'
          hfile: '@nikitajs/filetypes/src/hfile'
          krb5_conf: '@nikitajs/filetypes/src/krb5_conf'
          locale_gen: '@nikitajs/filetypes/src/locale_gen'
          my_cnf: '@nikitajs/filetypes/src/my_cnf'
          pacman_conf: '@nikitajs/filetypes/src/pacman_conf'
          ssh_authorized_keys: '@nikitajs/filetypes/src/ssh_authorized_keys'
          wireguard_conf: '@nikitajs/filetypes/src/wireguard_conf'
          yum_repo: '@nikitajs/filetypes/src/yum_repo'
          systemd:
            timesyncd: '@nikitajs/filetypes/src/systemd/timesyncd'
            resolved: '@nikitajs/filetypes/src/systemd/resolved'
