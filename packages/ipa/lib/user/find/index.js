
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
        method: 'user_find/1',
        params: [[], config.criterias || {}],
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
  metadata: {
    definitions: definitions
  }
};
