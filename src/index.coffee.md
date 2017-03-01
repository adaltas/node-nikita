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
        ctx = context()
        tree = []
        tree.push name
        builder = ->
          return registry[name].apply registry, arguments if name in ['get', 'register', 'deprecate', 'registered', 'unregister']
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
      assert: 'mecano/core/assert'
      kv:
        get: 'mecano/core/kv/get'
        engine: 'mecano/core/kv/engine'
        set: 'mecano/core/kv/set'
      cron:
        add: 'mecano/cron/add'
        remove: 'mecano/cron/remove'
      db:
        database:
          '': 'mecano/db/database'
          exists: 'mecano/db/database/exists'
          remove: 'mecano/db/database/remove'
          wait: 'mecano/db/database/wait'
        schema:
          '': 'mecano/db/schema'
          remove: 'mecano/db/schema/remove'
        user:
          '': 'mecano/db/user'
          exists: 'mecano/db/user/exists'
          remove: 'mecano/db/user/remove'
      docker:
        build: 'mecano/docker/build'
        checksum: 'mecano/docker/checksum'
        compose:
          '': 'mecano/docker/compose'
          up: 'mecano/docker/compose'
        cp: 'mecano/docker/cp'
        exec: 'mecano/docker/exec'
        kill: 'mecano/docker/kill'
        load: 'mecano/docker/load'
        pause: 'mecano/docker/pause'
        pull: 'mecano/docker/pull'
        restart: 'mecano/docker/restart'
        rm: 'mecano/docker/rm'
        rmi: 'mecano/docker/rmi'
        run: 'mecano/docker/run'
        save: 'mecano/docker/save'
        service: 'mecano/docker/service'
        start: 'mecano/docker/start'
        status: 'mecano/docker/status'
        stop: 'mecano/docker/stop'
        unpause: 'mecano/docker/unpause'
        volume_create: 'mecano/docker/volume_create'
        volume_rm: 'mecano/docker/volume_rm'
        wait: 'mecano/docker/wait'
      file:
        '': 'mecano/file'
        assert: 'mecano/file/assert'
        cache: 'mecano/file/cache'
        download: 'mecano/file/download'
        ini: 'mecano/file/ini'
        json: 'mecano/file/json'
        properties: 'mecano/file/properties'
        render: 'mecano/file/render'
        touch: 'mecano/file/touch'
        upload: 'mecano/file/upload'
        yaml: 'mecano/file/yaml'
      java:
        keystore_add: 'mecano/java/keystore_add'
        keystore_remove: 'mecano/java/keystore_remove'
      krb5:
        addprinc: 'mecano/krb5/addprinc'
        delprinc: 'mecano/krb5/delprinc'
        ktadd: 'mecano/krb5/ktadd'
        ticket: 'mecano/krb5/ticket'
      ldap:
        acl: 'mecano/ldap/acl'
        add: 'mecano/ldap/add'
        delete: 'mecano/ldap/delete'
        index: 'mecano/ldap/index'
        schema: 'mecano/ldap/schema'
        user: 'mecano/ldap/user'
      log:
        cli: 'mecano/log/cli'
        fs: 'mecano/log/fs'
        md: 'mecano/log/md'
        csv: 'mecano/log/csv'
      connection:
        assert: 'mecano/connection/assert'
        wait: '': 'mecano/connection/wait'
      service:
        '': 'mecano/service'
        discover: 'mecano/service/discover'
        install: 'mecano/service/install'
        init: 'mecano/service/init'
        remove: 'mecano/service/remove'
        restart: 'mecano/service/restart'
        start: 'mecano/service/start'
        startup: 'mecano/service/startup'
        status: 'mecano/service/status'
        stop: 'mecano/service/stop'
      system:
        cgroups: 'mecano/system/cgroups'
        chmod: 'mecano/system/chmod'
        chown: 'mecano/system/chown'
        copy: 'mecano/system/copy'
        discover: 'mecano/system/discover'
        execute: 'mecano/system/execute'
        group: 'mecano/system/group'
        limits: 'mecano/system/limits'
        link: 'mecano/system/link'
        mkdir: 'mecano/system/mkdir'
        move: 'mecano/system/move'
        remove: 'mecano/system/remove'
        tmpfs: 'mecano/system/tmpfs'
        user: 'mecano/system/user'
      ssh:
        open: 'mecano/ssh/open'
        close: 'mecano/ssh/close'
        root: 'mecano/ssh/root'
      tools:
        backup: 'mecano/tools/backup'
        compress: 'mecano/tools/compress'
        extract: 'mecano/tools/extract'
        iptables: 'mecano/tools/iptables'
        git: 'mecano/tools/git'
      wait:
        '': 'mecano/wait'
        execute: 'mecano/wait/execute'
        exist: 'mecano/wait/exist'
    
    # Backward compatibility
    registry.deprecate 'backup', 'mecano/tools/backup'
    registry.deprecate 'cgroups', 'mecano/system/cgroups'
    registry.deprecate 'chmod', 'mecano/system/chmod'
    registry.deprecate 'chown', 'mecano/system/chown'
    registry.deprecate 'compress', 'mecano/tools/compress'
    registry.deprecate 'copy', 'mecano/system/copy'
    registry.deprecate 'cron_add', 'mecano/cron/add'
    registry.deprecate 'cron_remove', 'mecano/cron/remove'
    registry.deprecate 'docker_build', 'mecano/docker/build'
    registry.deprecate 'docker_checksum', 'mecano/docker/checksum'
    registry.deprecate 'docker_cp', 'mecano/docker/cp'
    registry.deprecate 'docker_exec', 'mecano/docker/exec'
    registry.deprecate 'docker_kill', 'mecano/docker/kill'
    registry.deprecate 'docker_load', 'mecano/docker/load'
    registry.deprecate 'docker_pause', 'mecano/docker/pause'
    registry.deprecate 'docker_restart', 'mecano/docker/restart'
    registry.deprecate 'docker_rm', 'mecano/docker/rm'
    registry.deprecate 'docker_rmi', 'mecano/docker/rmi'
    registry.deprecate 'docker_run', 'mecano/docker/run'
    registry.deprecate 'docker_save', 'mecano/docker/save'
    registry.deprecate 'docker_service', 'mecano/docker/service'
    registry.deprecate 'docker_start', 'mecano/docker/start'
    registry.deprecate 'docker_status', 'mecano/docker/status'
    registry.deprecate 'docker_stop', 'mecano/docker/stop'
    registry.deprecate 'docker_unpause', 'mecano/docker/unpause'
    registry.deprecate 'docker_volume_create', 'mecano/docker/volume_create'
    registry.deprecate 'docker_volume_rm', 'mecano/docker/volume_rm'
    registry.deprecate 'docker_wait', 'mecano/docker/wait'
    registry.deprecate 'download', 'mecano/file/download'
    registry.deprecate 'execute', 'mecano/system/execute'
    registry.deprecate 'extract', 'mecano/tools/extract'
    registry.deprecate 'cache', 'mecano/file/cache'
    registry.deprecate 'git', 'mecano/tools/git'
    registry.deprecate 'group', 'mecano/system/group'
    registry.deprecate 'java_keystore_add', 'mecano/java/keystore_add'
    registry.deprecate 'java_keystore_remove', 'mecano/java/keystore_remove'
    registry.deprecate 'iptables', 'mecano/tools/iptables'
    registry.deprecate 'krb5_addprinc', 'mecano/krb5/addprinc'
    registry.deprecate 'krb5_delprinc', 'mecano/krb5/delprinc'
    registry.deprecate 'krb5_ktadd', 'mecano/krb5/ktadd'
    registry.deprecate 'ldap_acl', 'mecano/ldap/acl'
    registry.deprecate 'ldap_add', 'mecano/ldap/add'
    registry.deprecate 'ldap_delete', 'mecano/ldap/delete'
    registry.deprecate 'ldap_index', 'mecano/ldap/index'
    registry.deprecate 'ldap_schema', 'mecano/ldap/schema'
    registry.deprecate 'ldap_user', 'mecano/ldap/user'
    registry.deprecate 'link', 'mecano/system/link'
    registry.deprecate 'mkdir', 'mecano/system/mkdir'
    registry.deprecate 'move', 'mecano/system/move'
    registry.deprecate 'remove', 'mecano/system/remove'
    registry.deprecate 'render', 'mecano/file/render'
    registry.deprecate 'service_install', 'mecano/service/install'
    registry.deprecate 'service_remove', 'mecano/service/remove'
    registry.deprecate 'service_restart', 'mecano/service/restart'
    registry.deprecate 'service_start', 'mecano/service/start'
    registry.deprecate 'service_startup', 'mecano/service/startup'
    registry.deprecate 'service_status', 'mecano/service/status'
    registry.deprecate 'service_stop', 'mecano/service/stop'
    registry.deprecate 'system_limits', 'mecano/system/limits'
    registry.deprecate 'touch', 'mecano/file/touch'
    registry.deprecate 'upload', 'mecano/file/upload'
    registry.deprecate 'user', 'mecano/system/user'
    registry.deprecate 'wait_connect', 'mecano/connection/wait'
    registry.deprecate 'wait_execute', 'mecano/wait/execute'
    registry.deprecate 'wait_exist', 'mecano/wait/exist'
    registry.deprecate 'write', 'mecano/file'
    registry.deprecate 'write_ini', 'mecano/file/ini'
    registry.deprecate 'write_properties', 'mecano/file/properties'
    registry.deprecate 'write_yaml', 'mecano/file/yaml'
