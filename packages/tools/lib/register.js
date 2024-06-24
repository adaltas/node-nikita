
// Dependencies
import registry from "@nikitajs/core/registry";
import '@nikitajs/file/register';
import '@nikitajs/service/register';

// Action registration
const actions = {
  tools: {
    backup: '@nikitajs/tools/backup',
    compress: '@nikitajs/tools/compress',
    cron: {
      add: '@nikitajs/tools/cron/add',
      list: '@nikitajs/tools/cron/list',
      remove: '@nikitajs/tools/cron/remove',
      reset: '@nikitajs/tools/cron/reset'
    },
    extract: '@nikitajs/tools/extract',
    dconf: '@nikitajs/tools/dconf',
    iptables: '@nikitajs/tools/iptables',
    git: '@nikitajs/tools/git',
    npm: {
      '': '@nikitajs/tools/npm',
      list: '@nikitajs/tools/npm/list',
      outdated: '@nikitajs/tools/npm/outdated',
      uninstall: '@nikitajs/tools/npm/uninstall',
      upgrade: '@nikitajs/tools/npm/upgrade'
    },
    repo: '@nikitajs/tools/repo',
    rubygems: {
      'fetch': '@nikitajs/tools/rubygems/fetch',
      'install': '@nikitajs/tools/rubygems/install',
      'remove': '@nikitajs/tools/rubygems/remove'
    },
    ssh: {
      keygen: '@nikitajs/tools/ssh/keygen'
    },
    sysctl: {
      'file': {
        '': '@nikitajs/tools/sysctl/file',
        'read': '@nikitajs/tools/sysctl/file/read'
      }
    }
  }
};

await registry.register(actions);
