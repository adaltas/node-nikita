
// Dependencies
const definitions = require("./schema.json");

// ## Hooks
var handler, on_action, utils;

on_action = function({config}) {
  if (!Array.isArray(config.rules)) {
    return config.rules = [config.rules];
  }
};

// ## Schema definitions

// ## Handler
handler = async function({
    config,
    tools: {log}
  }) {
  var $status, command, newrules, oldrules, stdout;
  log({
    message: "List existing rules",
    level: 'WARN'
  });
  ({$status} = (await this.service.status({
    name: 'iptables'
  })));
  if (!$status) {
    throw Error("Service iptables not started");
  }
  ({stdout} = (await this.execute({
    $shy: true,
    command: 'iptables -S',
    sudo: config.sudo
  })));
  oldrules = utils.iptables.parse(stdout);
  newrules = utils.iptables.normalize(config.rules);
  command = utils.iptables.command(oldrules, newrules);
  if (!command.length) {
    return;
  }
  log({
    message: `${command.length} modified rules`,
    level: 'WARN'
  });
  return (await this.execute({
    command: `${command.join('; ')}; service iptables save;`,
    sudo: config.sudo,
    trap: true
  }));
};

// ## Exports
module.exports = {
  handler: handler,
  hooks: {
    on_action: on_action
  },
  metadata: {
    definitions: definitions
  }
};

// ## Dependencies
utils = require('../utils');

// ## IPTables References

// List rules in readable format: `iptables -L --line-numbers -nv`
// List rules in save format: `iptables -S -v`
