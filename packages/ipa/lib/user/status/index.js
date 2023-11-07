
// Dependencies
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function({config}) {
    var base, data, error;
    if ((base = config.connection.http_headers)['Referer'] == null) {
      base['Referer'] = config.connection.referer || config.connection.url;
    }
    ({data} = (await this.network.http(config.connection, {
      negotiate: true,
      method: 'POST',
      data: {
        method: 'user_status/1',
        params: [[config.uid], {}],
        id: 0
      }
    })));
    if (data.error) {
      error = Error(data.error.message);
      error.code = data.error.code;
      throw error;
    } else {
      return {
        // Note, result is an array, get the first and only element
        result: data.result.result[0]
      };
    }
  },
  hooks: {
    on_action: function({config}) {
      if (config.uid == null) {
        config.uid = config.username;
      }
      delete config.username;
    }
  },
  metadata: {
    definitions: definitions
  }
};
