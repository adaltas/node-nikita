
const utils = require('@nikitajs/core/lib/utils');
const diff = require('./diff');
const hfile = require('./hfile');
const ini = require('./ini');
const partial = require('./partial');

module.exports = {
  ...utils,
  diff: diff,
  hfile: hfile,
  ini: ini,
  partial: partial,
};
