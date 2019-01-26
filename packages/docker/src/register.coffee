
require('@nikita/core/lib/registry')
.register
  docker:
    build: '@nikita/docker/src/build'
    checksum: '@nikita/docker/src/checksum'
    compose:
      '': '@nikita/docker/src/compose'
      up: '@nikita/docker/src/compose'
    cp: '@nikita/docker/src/cp'
    exec: '@nikita/docker/src/exec'
    kill: '@nikita/docker/src/kill'
    load: '@nikita/docker/src/load'
    pause: '@nikita/docker/src/pause'
    pull: '@nikita/docker/src/pull'
    restart: '@nikita/docker/src/restart'
    rm: '@nikita/docker/src/rm'
    rmi: '@nikita/docker/src/rmi'
    run: '@nikita/docker/src/run'
    save: '@nikita/docker/src/save'
    service: '@nikita/docker/src/service'
    start: '@nikita/docker/src/start'
    status: '@nikita/docker/src/status'
    stop: '@nikita/docker/src/stop'
    unpause: '@nikita/docker/src/unpause'
    volume_create: '@nikita/docker/src/volume_create'
    volume_rm: '@nikita/docker/src/volume_rm'
    wait: '@nikita/docker/src/wait'
