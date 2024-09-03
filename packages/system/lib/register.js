// Dependencies
import "@nikitajs/file/register";
import registry from "@nikitajs/core/registry";

const actions = {
  system: {
    cgroups: "@nikitajs/system/cgroups",
    group: {
      "": "@nikitajs/system/group",
      read: "@nikitajs/system/group/read",
      remove: "@nikitajs/system/group/remove",
    },
    info: {
      disks: "@nikitajs/system/info/disks",
      os: "@nikitajs/system/info/os",
    },
    limits: "@nikitajs/system/limits",
    mod: "@nikitajs/system/mod",
    running: "@nikitajs/system/running",
    tmpfs: "@nikitajs/system/tmpfs",
    uid_gid: "@nikitajs/system/uid_gid",
    user: {
      "": "@nikitajs/system/user",
      read: "@nikitajs/system/user/read",
      remove: "@nikitajs/system/user/remove",
    },
  },
};

await registry.register(actions);
