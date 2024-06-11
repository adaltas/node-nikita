
// Dependencies
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function({config}) {
    config.connection.http_headers['Referer'] ??= config.connection.referer || config.connection.url;
    try {
      await this.ipa.group.show({
        connection: config.connection,
        cn: config.cn
      });
      return {
        $status: true,
        exists: true
      };
    } catch (error) {
      if (error.code !== 4001) { // group not found
        throw error;
      }
      return {
        $status: false,
        exists: false
      };
    }
  },
  metadata: {
    definitions: definitions,
    shy: true
  }
};
