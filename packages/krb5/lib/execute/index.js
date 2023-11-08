
// Dependencies
const utils = require('@nikitajs/core/lib/utils');
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function({config}) {
    const realm = config.admin.realm ? `-r ${config.admin.realm}` : '';
    const {stdout} = await this.execute({
      command: config.admin.principal ? `kadmin ${realm} -p ${config.admin.principal} -s ${config.admin.server} -w ${config.admin.password} -q '${config.command}'` : `kadmin.local ${realm} -q '${config.command}'`
    });
    if (config.grep && typeof config.grep === 'string') {
      return {
        stdout: stdout,
        $status: stdout.split('\n').some(function(line) {
          return line === config.grep;
        })
      };
    }
    if (config.grep && utils.regexp.is(config.grep)) {
      return {
        stdout: stdout,
        $status: stdout.split("\n").some((line) => config.grep.test(line)),
      };
    }
    return {
      $status: true,
      stdout: stdout
    };
  },
  hooks: {
    on_action: function({config}) {
      if (config.egrep != null) {
        throw Error('Deprecated config `egrep`');
      }
    }
  },
  metadata: {
    global: 'krb5',
    definitions: definitions
  }
};
