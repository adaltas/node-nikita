// Dependencies
import registry from "@nikitajs/core/registry";

// Action registration
const actions = {
  db: {
    database: {
      "": "@nikitajs/db/database",
      exists: "@nikitajs/db/database/exists",
      remove: "@nikitajs/db/database/remove",
      wait: "@nikitajs/db/database/wait",
    },
    query: "@nikitajs/db/query",
    schema: {
      "": "@nikitajs/db/schema",
      exists: "@nikitajs/db/schema/exists",
      list: "@nikitajs/db/schema/list",
      remove: "@nikitajs/db/schema/remove",
    },
    user: {
      "": "@nikitajs/db/user",
      exists: "@nikitajs/db/user/exists",
      remove: "@nikitajs/db/user/remove",
    },
  },
};

await registry.register(actions);
