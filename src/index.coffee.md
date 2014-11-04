# Mecano

Mecano gather a set of functions usually used during system deployment. All the
functions share a common API with flexible options.

*   Run actions both locally and remotely over SSH.
*   Ability to see if an action had an effect through the second argument
    provided in the callback.
*   Common API with options and callback arguments and calling the callback with
    an error and the number of affected actions.
*   Run one or multiple actions depending on option argument being an object or
    an array of objects.

Here's the list of available functions:

    mecano = module.exports =
      chown: require './chown'
      chmod: require './chmod'
      copy: require './copy'
      download: require './download'
      execute: require './execute'
      extract: require './extract'
      git: require './git'
      group: require './group'
      ini: require './ini'
      iptables: require './iptables'
      krb5_ktadd: require './krb5_ktadd'
      krb5_addprinc: require './krb5_addprinc'
      krb5_delprinc: require './krb5_delprinc'
      ldap_acl: require './ldap_acl'
      ldap_add: require './ldap_add'
      ldap_index: require './ldap_index'
      ldap_schema: require './ldap_schema'
      ldap_user: require './ldap_user'
      link: require './link'
      mkdir: require './mkdir'
      move: require './move'
      remove: require './remove'
      render: require './render'
      service: require './service'
      touch: require './touch'
      upload: require './upload'
      user: require './user'
      write: require './write'
