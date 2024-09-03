// Dependencies
import registry from "@nikitajs/core/registry";

// Action registration
const actions = {
  file: {
    "": "@nikitajs/file",
    cache: "@nikitajs/file/cache",
    cson: "@nikitajs/file/cson",
    download: "@nikitajs/file/download",
    ini: {
      "": "@nikitajs/file/ini",
      read: "@nikitajs/file/ini/read",
    },
    json: "@nikitajs/file/json",
    properties: {
      "": "@nikitajs/file/properties",
      read: "@nikitajs/file/properties/read",
    },
    render: "@nikitajs/file/render",
    touch: "@nikitajs/file/touch",
    types: {
      systemd: {
        resolved: "@nikitajs/file/types/systemd/resolved",
        timesyncd: "@nikitajs/file/types/systemd/timesyncd",
      },
      ceph_conf: "@nikitajs/file/types/ceph_conf",
      hfile: "@nikitajs/file/types/hfile",
      krb5_conf: "@nikitajs/file/types/krb5_conf",
      locale_gen: "@nikitajs/file/types/locale_gen",
      my_cnf: "@nikitajs/file/types/my_cnf",
      pacman_conf: "@nikitajs/file/types/pacman_conf",
      ssh_authorized_keys: "@nikitajs/file/types/ssh_authorized_keys",
      wireguard_conf: "@nikitajs/file/types/wireguard_conf",
      yum_repo: "@nikitajs/file/types/yum_repo",
    },
    upload: "@nikitajs/file/upload",
    yaml: "@nikitajs/file/yaml",
  },
};

await registry.register(actions);
