// Dependencies
const definitions = require('./schema.json');
const utils = require('../utils');
const esa = utils.string.escapeshellarg;

// Action
module.exports = {
  handler: async function({config}) {
    const opt = [
      config.user ? `--user ${config.user}` : void 0,
      config.cwd ? `--cwd ${utils.string.escapeshellarg(config.cwd)}` : void 0,
      ...Object.keys(config.env).map(
        (k) => `--env ${esa(k)}=${esa(config.env[k])}`
      ),
    ].join(" ");
    // Note, `trap` and `env` apply to `lxc exec` and not to `execute`
    config.trap = void 0;
    config.env = void 0;
    return await this.execute(config, {
      command: [`cat <<'NIKITALXDEXEC' | lxc exec ${opt} ${config.container} -- ${config.shell}`, config.trap ? 'set -e' : void 0, config.command, 'NIKITALXDEXEC'].join('\n')
    });
  },
  metadata: {
    definitions: definitions
  }
};
