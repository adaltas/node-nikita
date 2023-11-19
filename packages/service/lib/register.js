
// Dependencies
import registry from "@nikitajs/core/registry";
import "@nikitajs/file/register";

// Action registration
const actions = {
  service: {
    '': '@nikitajs/service',
    assert: '@nikitajs/service/assert',
    discover: '@nikitajs/service/discover',
    install: '@nikitajs/service/install',
    installed: '@nikitajs/service/installed',
    init: '@nikitajs/service/init',
    outdated: '@nikitajs/service/outdated',
    remove: '@nikitajs/service/remove',
    restart: '@nikitajs/service/restart',
    start: '@nikitajs/service/start',
    startup: '@nikitajs/service/startup',
    status: '@nikitajs/service/status',
    stop: '@nikitajs/service/stop'
  }
};

await registry.register(actions)
