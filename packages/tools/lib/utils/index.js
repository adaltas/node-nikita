
const utils = require('@nikitajs/core/lib/utils');
const diff = require('@nikitajs/file/lib/utils/diff');
const iptables = require('./iptables');

module.exports = {
  ...utils,
  diff: diff,
  iptables: iptables
};
