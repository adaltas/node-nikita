// Dependencies
import registry from "@nikitajs/core/registry";

// Action registration
import "@nikitajs/file/register";
import "@nikitajs/network/register";

// Actions
const actions = {
  incus: {
    cluster: {
      "": "@nikitajs/incus/cluster",
      stop: "@nikitajs/incus/cluster/stop",
      delete: "@nikitajs/incus/cluster/delete",
    },
    config: {
      device: {
        "": "@nikitajs/incus/config/device",
        delete: "@nikitajs/incus/config/device/delete",
        exists: "@nikitajs/incus/config/device/exists",
        show: "@nikitajs/incus/config/device/show",
      },
      set: "@nikitajs/incus/config/set",
    },
    exists: "@nikitajs/incus/exists",
    init: "@nikitajs/incus/init",
    info: "@nikitajs/incus/info",
    delete: "@nikitajs/incus/delete",
    exec: "@nikitajs/incus/exec",
    file: {
      exists: "@nikitajs/incus/file/exists",
      pull: "@nikitajs/incus/file/pull",
      push: "@nikitajs/incus/file/push",
      read: "@nikitajs/incus/file/read",
    },
    goodies: {
      prlimit: "@nikitajs/incus/goodies/prlimit",
    },
    operation: {
      list: "@nikitajs/incus/operation/list",
    },
    network: {
      "": "@nikitajs/incus/network",
      attach: "@nikitajs/incus/network/attach",
      create: "@nikitajs/incus/network",
      detach: "@nikitajs/incus/network/detach",
      delete: "@nikitajs/incus/network/delete",
      exists: "@nikitajs/incus/network/exists",
      list: "@nikitajs/incus/network/list",
      set: "@nikitajs/incus/network/set",
      show: "@nikitajs/incus/network/show",
    },
    query: "@nikitajs/incus/query",
    list: "@nikitajs/incus/list",
    project: {
      "": "@nikitajs/incus/project",
      delete: "@nikitajs/incus/project/delete",
      exists: "@nikitajs/incus/project/exists",
      list: "@nikitajs/incus/project/list",
    },
    start: "@nikitajs/incus/start",
    state: {
      "": "@nikitajs/incus/state",
      running: "@nikitajs/incus/state/running",
    },
    stop: "@nikitajs/incus/stop",
    storage: {
      "": "@nikitajs/incus/storage",
      delete: "@nikitajs/incus/storage/delete",
      exists: "@nikitajs/incus/storage/exists",
      set: "@nikitajs/incus/storage/set",
      show: "@nikitajs/incus/storage/show",
      list: "@nikitajs/incus/storage/list",
      volume: {
        "": "@nikitajs/incus/storage/volume",
        delete: "@nikitajs/incus/storage/volume/delete",
        list: "@nikitajs/incus/storage/volume/list",
        get: "@nikitajs/incus/storage/volume/get",
        attach: "@nikitajs/incus/storage/volume/attach",
      },
    },
    wait: {
      ready: "@nikitajs/incus/wait/ready",
    },
    resources: "@nikitajs/incus/resources",
  },
};

await registry.register(actions);
