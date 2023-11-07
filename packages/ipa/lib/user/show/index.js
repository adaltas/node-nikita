
// Dependencies
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function({config}) {
    config.connection.http_headers['Referer'] ??= config.connection.referer || config.connection.url;
    const {data} = await this.network.http(config.connection, {
      negotiate: true,
      method: 'POST',
      data: {
        method: 'user_show/1',
        params: [[config.uid], {}],
        id: 0
      }
    });
    if (data.error) {
      const error = Error(data.error.message);
      error.code = data.error.code;
      throw error;
    }
    return {
      result: data.result.result
    };
  },
  hooks: {
    on_action: function({config}) {
      if (config.uid == null) {
        config.uid = config.username;
      }
      return delete config.username;
    }
  },
  metadata: {
    definitions: definitions
  }
};
