
// Dependencies
import '@nikitajs/file/register';
import registry from "@nikitajs/core/registry";

// Action registration
const actions = {
  docker: {
    build: '@nikitajs/docker/build',
    compose: {
      '': '@nikitajs/docker/compose',
      up: '@nikitajs/docker/compose'
    },
    cp: '@nikitajs/docker/cp',
    exec: '@nikitajs/docker/exec',
    images: '@nikitajs/docker/images',
    inspect: '@nikitajs/docker/inspect',
    kill: '@nikitajs/docker/kill',
    load: '@nikitajs/docker/load',
    pause: '@nikitajs/docker/pause',
    ps: '@nikitajs/docker/ps',
    pull: '@nikitajs/docker/pull',
    restart: '@nikitajs/docker/restart',
    rm: '@nikitajs/docker/rm',
    rmi: '@nikitajs/docker/rmi',
    run: '@nikitajs/docker/run',
    save: '@nikitajs/docker/save',
    start: '@nikitajs/docker/start',
    stop: '@nikitajs/docker/stop',
    tools: {
      checksum: '@nikitajs/docker/tools/checksum',
      execute: '@nikitajs/docker/tools/execute',
      service: '@nikitajs/docker/tools/service',
      status: '@nikitajs/docker/tools/status'
    },
    // unpause: '@nikitajs/docker/unpause'
    volume_create: '@nikitajs/docker/volume_create',
    volume_rm: '@nikitajs/docker/volume_rm',
    wait: '@nikitajs/docker/wait'
  }
};

await registry.register(actions)
