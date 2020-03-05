// Generated by CoffeeScript 2.5.0
// registration of `nikita.tools` actions

//# Dependency
var register;

({register} = require('@nikitajs/core/lib/registry'));

//# Action registration
register({
  tools: {
    backup: '@nikitajs/tools/lib/backup',
    compress: '@nikitajs/tools/lib/compress',
    cron: {
      add: '@nikitajs/tools/lib/cron/add',
      remove: '@nikitajs/tools/lib/cron/remove'
    },
    extract: '@nikitajs/tools/lib/extract',
    dconf: '@nikitajs/tools/lib/dconf',
    rubygems: {
      'fetch': '@nikitajs/tools/lib/rubygems/fetch',
      'install': '@nikitajs/tools/lib/rubygems/install',
      'remove': '@nikitajs/tools/lib/rubygems/remove'
    },
    iptables: '@nikitajs/tools/lib/iptables',
    git: '@nikitajs/tools/lib/git',
    repo: '@nikitajs/tools/lib/repo',
    ssh: {
      keygen: '@nikitajs/tools/lib/ssh/keygen'
    },
    sysctl: '@nikitajs/tools/lib/sysctl'
  }
});
