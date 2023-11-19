// Dependencies
import "@nikitajs/file/register";
import registry from "@nikitajs/core/registry";

// Action registration
const actions = {
  java: {
    keystore: {
      exists: "@nikitajs/java/keystore/exists",
      add: "@nikitajs/java/keystore/add",
      remove: "@nikitajs/java/keystore/remove",
    },
  },
};

await registry.register(actions);
