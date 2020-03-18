
# Registration of `nikita.docker` actions

## Dependency

    {register} = require '@nikitajs/core/lib/registry'

## Action registration

    register module.exports =
      docker:
        build: '@nikitajs/docker/src/build'
        checksum: '@nikitajs/docker/src/checksum'
        compose:
          '': '@nikitajs/docker/src/compose'
          up: '@nikitajs/docker/src/compose'
        cp: '@nikitajs/docker/src/cp'
        exec: '@nikitajs/docker/src/exec'
        kill: '@nikitajs/docker/src/kill'
        load: '@nikitajs/docker/src/load'
        pause: '@nikitajs/docker/src/pause'
        pull: '@nikitajs/docker/src/pull'
        restart: '@nikitajs/docker/src/restart'
        rm: '@nikitajs/docker/src/rm'
        rmi: '@nikitajs/docker/src/rmi'
        run: '@nikitajs/docker/src/run'
        save: '@nikitajs/docker/src/save'
        service: '@nikitajs/docker/src/service'
        start: '@nikitajs/docker/src/start'
        status: '@nikitajs/docker/src/status'
        stop: '@nikitajs/docker/src/stop'
        unpause: '@nikitajs/docker/src/unpause'
        volume_create: '@nikitajs/docker/src/volume_create'
        volume_rm: '@nikitajs/docker/src/volume_rm'
        wait: '@nikitajs/docker/src/wait'
