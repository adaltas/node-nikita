
require '@nikita/core/lib/registry'
.register
  krb5:
    addprinc: '@nikita/krb5/src/addprinc'
    delprinc: '@nikita/krb5/src/delprinc'
    ktadd: '@nikita/krb5/src/ktadd'
    ticket: '@nikita/krb5/src/ticket'
    ktutil:
      add: '@nikita/krb5/src/ktutil/add'
