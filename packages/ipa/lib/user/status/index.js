
// Dependencies
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function({config}) {
    config.connection.http_headers['Referer'] ??= config.connection.referer || config.connection.url;
    const {data} = await this.network.http(config.connection, {
      negotiate: true,
      method: 'POST',
      data: {
        method: 'user_status/1',
        params: [[config.uid], {}],
        id: 0
      }
    });
    if (data.error) {
      const error = Error(data.error.message);
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
