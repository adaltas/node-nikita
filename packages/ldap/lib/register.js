import registry from "@nikitajs/core/registry";

const actions = {
  ldap: {
    acl: "@nikitajs/ldap/acl",
    add: "@nikitajs/ldap/add",
    delete: "@nikitajs/ldap/delete",
    index: "@nikitajs/ldap/index",
    modify: "@nikitajs/ldap/modify",
    schema: "@nikitajs/ldap/schema",
    search: "@nikitajs/ldap/search",
    tools: {
      database: "@nikitajs/ldap/tools/database",
      databases: "@nikitajs/ldap/tools/databases",
    },
    user: "@nikitajs/ldap/user",
  },
};

await registry.register(actions);
