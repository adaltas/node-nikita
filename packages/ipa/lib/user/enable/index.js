
// Dependencies
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function({config}) {
    config.connection.http_headers['Referer'] ??= config.connection.referer || config.connection.url;
    const {
      result: { nsaccountlock },
    } = await this.ipa.user.show({
      $shy: false,
      connection: config.connection,
      uid: config.uid,
    });
    if (nsaccountlock === false) {
      return false;
    }
    await this.network.http(config.connection, {
      negotiate: true,
      method: 'POST',
      data: {
        method: "user_enable/1",
        params: [[config.uid], {}],
        id: 0
      }
    });
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
