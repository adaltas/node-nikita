
// Dependencies
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function({config}) {
    config.connection.http_headers['Referer'] ??= config.connection.referer || config.connection.url;
    try {
      await this.ipa.user.show({
        connection: config.connection,
        uid: config.uid
      });
      return {
        $status: true,
        exists: true
      };
    } catch (error) {
      if (error.code !== 4001) { // user not found
        throw error;
      }
      return {
        $status: false,
        exists: false
      };
    }
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
    definitions: definitions,
    shy: true
  }
};
