// Generated by CoffeeScript 2.5.0
var registry;

registry = require('@nikitajs/core/lib/registry');

registry.register({
  file: {
    types: {
      ceph_conf: '@nikitajs/filetypes/lib/ceph_conf',
      hfile: '@nikitajs/filetypes/lib/hfile',
      krb5_conf: '@nikitajs/filetypes/lib/krb5_conf',
      locale_gen: '@nikitajs/filetypes/lib/locale_gen',
      my_cnf: '@nikitajs/filetypes/lib/my_cnf',
      pacman_conf: '@nikitajs/filetypes/lib/pacman_conf',
      ssh_authorized_keys: '@nikitajs/filetypes/lib/ssh_authorized_keys',
      yum_repo: '@nikitajs/filetypes/lib/yum_repo',
      systemd: {
        timesyncd: '@nikitajs/filetypes/lib/systemd/timesyncd',
        resolved: '@nikitajs/filetypes/lib/systemd/resolved'
      }
    }
  }
});
