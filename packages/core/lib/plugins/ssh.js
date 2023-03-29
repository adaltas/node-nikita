
/*
# Plugin @nikitajs/core/lib/plugins/ssh

Pass an SSH connection to an action. The connection is accessible with the
`action.ssh` property.
*/

// Denpendencies
const {merge} = require('mixme');
const utils = require('../utils');
const session = require('../session');
// Nikita plugins
const events = require('./tools/events');
const find = require('./tools/find');
const log = require('./tools/log');
const status = require('./output/status');
const raw = require('./metadata/raw');
const history = require('./history');

// Plugin
module.exports = {
  name: '@nikitajs/core/lib/plugins/ssh',
  require: [
    '@nikitajs/core/lib/plugins/tools/find'
  ],
  hooks: {
    'nikita:action': async function(action) {
      // Is there a connection to open
      if (action.ssh && !utils.ssh.is(action.ssh)) {
        let {ssh} = await session.with_options([{}], {
          plugins: [
            events, find, log,
            status, raw, history,
          ] // Need to inject `tools.log`
        }).ssh.open(action.ssh);
        action.metadata.ssh_dispose = true;
        action.ssh = ssh;
        return;
      }
      // Find SSH connection in parent actions
      let ssh = await action.tools.find( (action) => action.ssh );
      if (ssh) {
        if (!utils.ssh.is(ssh)) {
          throw utils.error('NIKITA_SSH_INVALID_STATE', ['the `ssh` property is not a connection', `got ${JSON.stringify(ssh)}`]);
        }
        action.ssh = ssh;
        return;
      } else if (ssh === null || ssh === false) {
        if (action.ssh !== undefined) {
          action.ssh = null;
        }
        return;
      } else if (ssh !== void 0) {
        throw utils.error('NIKITA_SSH_INVALID_VALUE', ['when disabled, the `ssh` property must be `null` or `false`,', 'when enable, the `ssh` property must be a connection or a configuration object', `got ${JSON.stringify(ssh)}`]);
      }
      // Find SSH open in previous siblings
      for (let i = 0; i < action.siblings.length; i++) {
        const sibling = action.siblings[i];
        if (sibling.metadata.module !== '@nikitajs/core/lib/actions/ssh/open') {
          continue;
        }
        if (sibling.output.ssh) {
          ssh = sibling.output.ssh;
          break;
        }
      }
      // Then only set the connection if still open
      if (ssh && (ssh._sshstream?.writable || ssh._sock?.writable)) {
        action.ssh = ssh;
      }
    },
    'nikita:result': async function({action}) {
      if (action.metadata.ssh_dispose) {
        return (await session.with_options([{}], {
          plugins: [require('./tools/events'), require('./tools/find'), require('./tools/log'), require('./output/status'), require('./metadata/raw'), require('./history')] // Need to inject `tools.log`
        }).ssh.close({
          ssh: action.ssh
        }));
      }
    }
  }
};
