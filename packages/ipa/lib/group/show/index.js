
// Dependencies
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function({config}) {
    config.connection.http_headers['Referer'] ??= config.connection.referer || config.connection.url;
    const {data} = await this.network.http(config.connection, {
      negotiate: true,
      method: 'POST',
      data: {
        method: "group_show/1",
        params: [[config.cn], {}],
        id: 0
      }
    });
    if (data.error) {
      const error = Error(data.error.message);
      error.code = data.error.code;
      throw error;
    } else {
      return {
        result: data.result.result
      };
    }
  },
  metadata: {
    definitions: definitions
  }
};
