// Dependencies
import "@nikitajs/network/register";
import registry from "@nikitajs/core/registry";

// Action registration
const actions = {
  ipa: {
    group: {
      "": "@nikitajs/ipa/group",
      add_member: "@nikitajs/ipa/group/add_member",
      del: "@nikitajs/ipa/group/del",
      exists: "@nikitajs/ipa/group/exists",
      show: "@nikitajs/ipa/group/show",
    },
    user: {
      "": "@nikitajs/ipa/user",
      disable: "@nikitajs/ipa/user/disable",
      del: "@nikitajs/ipa/user/del",
      enable: "@nikitajs/ipa/user/enable",
      exists: "@nikitajs/ipa/user/exists",
      find: "@nikitajs/ipa/user/find",
      show: "@nikitajs/ipa/user/show",
      status: "@nikitajs/ipa/user/status",
    },
    service: {
      "": "@nikitajs/ipa/service",
      del: "@nikitajs/ipa/service/del",
      exists: "@nikitajs/ipa/service/exists",
      show: "@nikitajs/ipa/service/show",
    },
  },
};

await registry.register(actions);
