
// Dependencies
import registry from "@nikitajs/core/registry";

// Action registration
const actions = {
  krb5: {
    addprinc: '@nikitajs/krb5/addprinc',
    delprinc: '@nikitajs/krb5/delprinc',
    execute: '@nikitajs/krb5/execute',
    ktadd: '@nikitajs/krb5/ktadd',
    ticket: '@nikitajs/krb5/ticket',
    ktutil: {
      add: '@nikitajs/krb5/ktutil/add'
    }
  }
};

await registry.register(actions)
