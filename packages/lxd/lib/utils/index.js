// Dependencies
const utils = require('@nikitajs/core/lib/utils');
const stderr_to_error_message = require('./stderr_to_error_message');

module.exports = {
  ...utils,
  stderr_to_error_message: stderr_to_error_message
};
