// Generated by CoffeeScript 2.5.1
// # `nikita.lxc.exec`

// Execute command in containers.

// ## Example

// ```js
// const {$status, stdout, stderr} = await nikita.lxc.exec({
//   container: "my-container",
//   command: "whoami"
// })
// console.info(`Command was executed: ${$status}`)
// console.info(stdout)
// ```

// ## Todo

// * Support `env` option

// ## Schema
var handler, schema, utils;

schema = {
  type: 'object',
  properties: {
    'container': {
      $ref: 'module://@nikitajs/lxd/lib/init#/properties/container'
    },
    'command': {
      type: 'string',
      description: `The command to execute.`
    },
    'cwd': {
      type: 'string',
      description: `Directory to run the command in (default /root).`
    },
    'env': {
      type: 'object',
      default: {},
      description: `Environment variable to set (e.g. HOME=/home/foo).`
    },
    'shell': {
      type: 'string',
      default: 'sh',
      description: `The shell in which to execute commands, for example \`sh\`, \`bash\` or
\`zsh\`.`
    },
    'trim': {
      $ref: 'module://@nikitajs/core/lib/actions/execute#/properties/trim'
    },
    'trap': {
      $ref: 'module://@nikitajs/core/lib/actions/execute#/properties/trap'
    },
    'user': {
      type: 'integer',
      description: `User ID to run the command as (default 0).`
    }
  },
  required: ['container', 'command']
};

// ## Handler
handler = async function({config}) {
  var k, opt, v;
  opt = [
    config.user ? `--user ${config.user}` : void 0,
    config.cwd ? `--cwd ${utils.string.escapeshellarg(config.cwd)}` : void 0,
    ...((function() {
      var ref,
    results;
      ref = config.env;
      results = [];
      for (k in ref) {
        v = ref[k];
        results.push('--env ' + utils.string.escapeshellarg(`${k}=${v}`));
      }
      return results;
    })())
  ].join(' ');
  // console.log config, opt
  return (await this.execute(config, {
    trap: false
  }, {
    command: [`cat <<'NIKITALXDEXEC' | lxc exec ${opt} ${config.container} -- ${config.shell}`, config.trap ? 'set -e' : void 0, config.command, 'NIKITALXDEXEC'].join('\n')
  }));
};

// ## Export
module.exports = {
  handler: handler,
  metadata: {
    schema: schema
  }
};

// ## Dependencies
utils = require('./utils');
