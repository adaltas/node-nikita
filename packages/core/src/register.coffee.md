
# Register

Register actions into the global namespace. The actions registered below will be
available to every Nikita sessions.

## Dependency

    {register} = require './registry'

## Action registration

    register module.exports =
      assert: '@nikitajs/core/src/core/assert'
      connection:
        assert: '@nikitajs/core/src/connection/assert'
        http: '@nikitajs/core/src/connection/http'
        wait: '': '@nikitajs/core/src/connection/wait'
      kv:
        get: '@nikitajs/core/src/core/kv/get'
        engine: '@nikitajs/core/src/core/kv/engine'
        set: '@nikitajs/core/src/core/kv/set'
      core:
        ping: '@nikitajs/core/src/core/ping'
      file:
        '': '@nikitajs/core/src/file'
        assert: '@nikitajs/core/src/file/assert'
        cache: '@nikitajs/core/src/file/cache'
        cson: '@nikitajs/core/src/file/cson'
        download: '@nikitajs/core/src/file/download'
        glob: '@nikitajs/core/src/file/glob'
        hash: '@nikitajs/core/src/file/hash'
        ini: '@nikitajs/core/src/file/ini'
        json: '@nikitajs/core/src/file/json'
        properties:
          '': '@nikitajs/core/src/file/properties'
          read: '@nikitajs/core/src/file/properties/read'
        render: '@nikitajs/core/src/file/render'
        touch: '@nikitajs/core/src/file/touch'
        upload: '@nikitajs/core/src/file/upload'
        yaml: '@nikitajs/core/src/file/yaml'
      log:
        '': '@nikitajs/core/src/log'
        cli: '@nikitajs/core/src/log/cli'
        fs: '@nikitajs/core/src/log/fs'
        md: '@nikitajs/core/src/log/md'
        csv: '@nikitajs/core/src/log/csv'
      system:
        authconfig: '@nikitajs/core/src/system/authconfig'
        cgroups: '@nikitajs/core/src/system/cgroups'
        chmod: '@nikitajs/core/src/system/chmod'
        chown: '@nikitajs/core/src/system/chown'
        copy: '@nikitajs/core/src/system/copy'
        discover: '@nikitajs/core/src/system/discover'
        execute:
          '': '@nikitajs/core/src/system/execute'
          'assert': '@nikitajs/core/src/system/execute/assert'
        group:
          '': '@nikitajs/core/src/system/group/index'
          read: '@nikitajs/core/src/system/group/read'
          remove: '@nikitajs/core/src/system/group/remove'
        info:
          'disks': '@nikitajs/core/src/system/info/disks'
          'system': '@nikitajs/core/src/system/info/system'
        limits: '@nikitajs/core/src/system/limits'
        link: '@nikitajs/core/src/system/link'
        mkdir: '@nikitajs/core/src/system/mkdir'
        mod: '@nikitajs/core/src/system/mod'
        move: '@nikitajs/core/src/system/move'
        remove: '@nikitajs/core/src/system/remove'
        running: '@nikitajs/core/src/system/running'
        tmpfs: '@nikitajs/core/src/system/tmpfs'
        uid_gid: '@nikitajs/core/src/system/uid_gid'
        user:
          '': '@nikitajs/core/src/system/user/index'
          read: '@nikitajs/core/src/system/user/read'
          remove: '@nikitajs/core/src/system/user/remove'
      wait:
        '': '@nikitajs/core/src/wait'
        execute: '@nikitajs/core/src/wait/execute'
        exist: '@nikitajs/core/src/wait/exist'
