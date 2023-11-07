
// Dependencies
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function({config}) {
    config.connection.http_headers['Referer'] ??= config.connection.referer || config.connection.url;
    const {exists} = await this.ipa.group.exists({
      connection: config.connection,
      cn: config.cn
    });
    // Add or modify a group
    const {data} = await this.network.http(config.connection, {
      negotiate: true,
      method: 'POST',
      data: {
        method: !exists ? "group_add/1" : "group_mod/1",
        params: [[config.cn], config.attributes],
        id: 0
      }
    });
    let result, $status;
    if (data.error != null) {
      // Exclude no modification error
      if (data.error.code !== 4202) {
        const error = Error(data.error.message);
        error.code = data.error.code;
        throw error;
      }
      $status = false;
    } else {
      result = data.result.result;
      $status = true;
    }
    // Get info even when no modification was performed
    if (!result) {
      ({result} = await this.ipa.group.show(config, {
        cn: config.cn
      }));
    }
    return {
      $status: $status,
      result: result
    };
  },
  metadata: {
    definitions: definitions
  }
};
