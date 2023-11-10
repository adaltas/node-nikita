
// Dependencies
require('@nikitajs/file/lib/register');
const registry = require('@nikitajs/core/lib/registry');

// Action registration
module.exports = {
  docker: {
    build: '@nikitajs/docker/lib/build',
    compose: {
      '': '@nikitajs/docker/lib/compose',
      up: '@nikitajs/docker/lib/compose'
    },
    cp: '@nikitajs/docker/lib/cp',
    exec: '@nikitajs/docker/lib/exec',
    inspect: '@nikitajs/docker/lib/inspect',
    kill: '@nikitajs/docker/lib/kill',
    load: '@nikitajs/docker/lib/load',
    pause: '@nikitajs/docker/lib/pause',
    pull: '@nikitajs/docker/lib/pull',
    restart: '@nikitajs/docker/lib/restart',
    rm: '@nikitajs/docker/lib/rm',
    rmi: '@nikitajs/docker/lib/rmi',
    run: '@nikitajs/docker/lib/run',
    save: '@nikitajs/docker/lib/save',
    start: '@nikitajs/docker/lib/start',
    stop: '@nikitajs/docker/lib/stop',
    tools: {
      checksum: '@nikitajs/docker/lib/tools/checksum',
      execute: '@nikitajs/docker/lib/tools/execute',
      service: '@nikitajs/docker/lib/tools/service',
      status: '@nikitajs/docker/lib/tools/status'
    },
    // unpause: '@nikitajs/docker/lib/unpause'
    volume_create: '@nikitajs/docker/lib/volume_create',
    volume_rm: '@nikitajs/docker/lib/volume_rm',
    wait: '@nikitajs/docker/lib/wait'
  }
};

(async function() {
  try {
    return (await registry.register(module.exports));
  } catch (error) {
    console.error(error.stack);
    return process.exit(1);
  }
})();
