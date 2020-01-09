
require '@nikitajs/core/lib/registry'
.register
  krb5:
    addprinc: '@nikitajs/krb5/src/addprinc'
    delprinc: '@nikitajs/krb5/src/delprinc'
    execute: '@nikitajs/krb5/src/execute'
    ktadd: '@nikitajs/krb5/src/ktadd'
    ticket: '@nikitajs/krb5/src/ticket'
    ktutil:
      add: '@nikitajs/krb5/src/ktutil/add'
