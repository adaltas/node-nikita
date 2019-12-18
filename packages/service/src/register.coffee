
registry = require '@nikitajs/core/lib/registry'

registry.register
  service:
    '': '@nikitajs/service/src'
    assert: '@nikitajs/service/src/assert'
    discover: '@nikitajs/service/src/discover'
    install: '@nikitajs/service/src/install'
    init: '@nikitajs/service/src/init'
    remove: '@nikitajs/service/src/remove'
    restart: '@nikitajs/service/src/restart'
    start: '@nikitajs/service/src/start'
    startup: '@nikitajs/service/src/startup'
    status: '@nikitajs/service/src/status'
    stop: '@nikitajs/service/src/stop'

registry.deprecate 'service_install', '@nikitajs/service/src/install'
registry.deprecate 'service_remove', '@nikitajs/service/src/remove'
registry.deprecate 'service_restart', '@nikitajs/service/src/restart'
registry.deprecate 'service_start', '@nikitajs/service/src/start'
registry.deprecate 'service_startup', '@nikitajs/service/src/startup'
registry.deprecate 'service_status', '@nikitajs/service/src/status'
registry.deprecate 'service_stop', '@nikitajs/service/src/stop'
