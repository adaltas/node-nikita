// Dependencies
const utils = require('../../utils');
const definitions = require('./schema.json');

// Errors
const errors = {
  NIKITA_HTTP_WAIT_TIMEOUT: function({config}) {
    return utils.error('NIKITA_HTTP_WAIT_TIMEOUT', [`timeout reached after ${config.timeout}ms.`]);
  }
};

// Action
module.exports = {
  handler: async function ({ config, tools: { log } }) {
    const start = Date.now();
    config.status_code = config.status_code.map(function (item) {
      if (typeof item === "string") {
        item = new RegExp("^" + item.replaceAll("x", "\\d") + "$");
      }
      return item;
    });
    let count = 0;
    while (true) {
      const { error, status_code } = await this.network.http({
        $relax: true,
        method: config.method,
        url: config.url,
        timeout: config.timeout,
      });
      log({
        message: error
          ? `Attemp ${count} failed with error`
          : `Attemp ${count} return status ${status_code}`,
        attempt: count,
        status_code: status_code,
      });
      if (
        !error &&
        config.status_code.some(function (code) {
          return code.test(status_code);
        })
      ) {
        return count > 0;
      }
      if (config.timeout && error.code === "CURLE_OPERATION_TIMEDOUT") {
        // HTTP request timeout
        throw errors.NIKITA_HTTP_WAIT_TIMEOUT({ config });
      }
      await this.wait(config.interval);
      // Action timeout
      if (config.timeout && start + config.timeout < Date.now()) {
        throw errors.NIKITA_HTTP_WAIT_TIMEOUT({ config });
      }
      count++;
    }
  },
  metadata: {
    definitions: definitions,
  },
};
