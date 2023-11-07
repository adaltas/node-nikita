
// Dependencies
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function({config}) {
    config.connection.http_headers['Referer'] ??= config.connection.referer || config.connection.url;
    const {$status} = await this.ipa.user.exists({
      $shy: false,
      connection: config.connection,
      uid: config.uid
    });
    if (!$status) {
      return;
    }
    await this.network.http(config.connection, {
      negotiate: true,
      method: 'POST',
      data: {
        method: "user_del/1",
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
