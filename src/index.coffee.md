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

## Source Code
    
    module.exports = new Proxy (-> context arguments...),
      get: (target, name) ->
        # return target[name] if target[name]
        ctx = context()
        tree = []
        tree.push name
        builder = ->
          return registry[name].apply registry, arguments if name in ['register', 'registered', 'unregister']
          a = ctx[tree.shift()]
          return a unless typeof a is 'function'
          while name = tree.shift()
            a[name]
          a.apply ctx, arguments
        proxy = new Proxy builder,
          get: (target, name) ->
            tree.push name
            proxy
        proxy

## Dependencies

    context = require './context'
    registry = require './registry'

## Register

    registry.register
      assert: require './core/assert'
      backup: require './core/backup'
      cache: require './core/cache'
      chmod: require './core/chmod'
      chown: require './core/chown'
      compress: require './core/compress'
      copy: require './core/copy'
      download: require './core/download'
      execute: require './core/execute'
      extract: require './core/extract'
      git: require './core/git'
      group: require './core/group'
      iptables: require './core/iptables'
      link: require './core/link'
      mkdir: require './core/mkdir'
      move: require './core/move'
      remove: require './core/remove'
      render: require './core/render'
      system_limits: require './core/system_limits'
      touch: require './core/touch'
      upload: require './core/upload'
      user: require './core/user'
      cron:
        add: require './cron/add'
        remove: require './cron/remove'
      db:
        database:
          add: require './db/database/add'
          remove: require './db/database/remove'
        schema:
          add: require './db/schema/add'
          remove: require './db/schema/remove'
        user:
          add: require './db/user/add'
          exists: require './db/user/exists'
          remove: require './db/user/remove'
      docker:
        build: require './docker/build'
        checksum: require './docker/checksum'
        cp: require './docker/cp'
        exec: require './docker/exec'
        kill: require './docker/kill'
        load: require './docker/load'
        pause: require './docker/pause'
        pull: require './docker/pull'
        restart: require './docker/restart'
        rm: require './docker/rm'
        rmi: require './docker/rmi'
        run: require './docker/run'
        save: require './docker/save'
        service: require './docker/service'
        start: require './docker/start'
        status: require './docker/status'
        stop: require './docker/stop'
        unpause: require './docker/unpause'
        volume_create: require './docker/volume_create'
        volume_rm: require './docker/volume_rm'
        wait: require './docker/wait'
      java:
        keystore_add: require './java/keystore_add'
        keystore_remove: require './java/keystore_remove'
      krb5:
        addprinc: require './krb5/addprinc'
        delprinc: require './krb5/delprinc'
        ktadd: require './krb5/ktadd'
      ldap:
        acl: require './ldap/acl'
        add: require './ldap/add'
        delete: require './ldap/delete'
        index: require './ldap/index'
        schema: require './ldap/schema'
        user: require './ldap/user'
      log:
        fs: require './log/fs'
        md: require './log/md'
        csv: require './log/csv'
      service:
        '': require './service'
        install: require './service/install'
        remove: require './service/remove'
        restart: require './service/restart'
        start: require './service/start'
        startup: require './service/startup'
        status: require './service/status'
        stop: require './service/stop'
      wait:
        '': require './wait/time'
        connect: '': require './wait/connect'
        execute: '': require './wait/execute'
        exist: '': require './wait/exist'
      write:
        '': require './write'
        assert: require './write/assert'
        ini: require './write/ini'
        properties: require './write/properties'
        yaml: require './write/yaml'
      # Backward compatibility
      cron_add: require './cron/add'
      cron_remove: require './cron/remove'
      docker_build: require './docker/build'
      docker_checksum: require './docker/checksum'
      docker_cp: require './docker/cp'
      docker_exec: require './docker/exec'
      docker_kill: require './docker/kill'
      docker_load: require './docker/load'
      docker_pause: require './docker/pause'
      docker_restart: require './docker/restart'
      docker_rm: require './docker/rm'
      docker_rmi: require './docker/rmi'
      docker_run: require './docker/run'
      docker_save: require './docker/save'
      docker_service: require './docker/service'
      docker_start: require './docker/start'
      docker_status: require './docker/status'
      docker_stop: require './docker/stop'
      docker_unpause: require './docker/unpause'
      docker_volume_create: require './docker/volume_create'
      docker_volume_rm: require './docker/volume_rm'
      docker_wait: require './docker/wait'
      java_keystore_add: require './java/keystore_add'
      java_keystore_remove: require './java/keystore_remove'
      krb5_addprinc: require './krb5/addprinc'
      krb5_delprinc: require './krb5/delprinc'
      krb5_ktadd: require './krb5/ktadd'
      ldap_acl: require './ldap/acl'
      ldap_add: require './ldap/add'
      ldap_delete: require './ldap/delete'
      ldap_index: require './ldap/index'
      ldap_schema: require './ldap/schema'
      ldap_user: require './ldap/user'
      service_install: require './service/install'
      service_remove: require './service/remove'
      service_restart: require './service/restart'
      service_start: require './service/start'
      service_startup: require './service/startup'
      service_status: require './service/status'
      service_stop: require './service/stop'
      wait_connect: require './wait/connect'
      wait_execute: require './wait/execute'
      wait_exist: require './wait/exist'
      write_ini: require './write/ini'
      write_properties: require './write/properties'
      write_yaml: require './write/yaml'
    
