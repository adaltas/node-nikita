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
      docker:
        build: require './docker/build'
        checksum: require './docker/checksum'
        cp: require './docker/cp'
        exec: require './docker/exec'
        kill: require './docker/kill'
        load: require './docker/load'
        pause: require './docker/pause'
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
        md: require './log/md'
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
        ini: require './write/ini'
        properties: require './write/properties'
        yaml: require './write/yaml'
    
