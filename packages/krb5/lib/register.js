
// Dependencies
const registry = require('@nikitajs/core/lib/registry');

// Action registration
module.exports = {
  krb5: {
    addprinc: '@nikitajs/krb5/lib/addprinc',
    delprinc: '@nikitajs/krb5/lib/delprinc',
    execute: '@nikitajs/krb5/lib/execute',
    ktadd: '@nikitajs/krb5/lib/ktadd',
    ticket: '@nikitajs/krb5/lib/ticket',
    ktutil: {
      add: '@nikitajs/krb5/lib/ktutil/add'
    }
  }
};

(async function() {
  try {
    return (await registry.register(module.exports));
  } catch (error) {
    console.error(error.stack);
    return process.exit(1);
  }
})();
