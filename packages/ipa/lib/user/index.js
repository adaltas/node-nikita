
// Dependencies
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function({config}) {
    config.connection.http_headers['Referer'] ??= config.connection.referer || config.connection.url;
    const {exists} = await this.ipa.user.exists({
      connection: config.connection,
      uid: config.uid
    });
    if (exists && !config.force_userpassword) {
      config.attributes.userpassword = undefined;
    }
    const {data} = await this.network.http(config.connection, {
      negotiate: true,
      method: 'POST',
      data: {
        method: !exists ? 'user_add/1' : 'user_mod/1',
        params: [[config.uid], config.attributes],
        id: 0
      }
    });
    let result, $status = true;
    if (data.error !== null) {
      if (data.error.code !== 4202) { // no modifications to be performed
        const error = Error(data.error.message);
        error.code = data.error.code;
        throw error;
      }
      $status = false;
    }else{
      result = data.result.result;
    }
    // Get info even when no modification was performed
    if (!result) {
      ({result} = await this.ipa.user.show({
        connection: config.connection,
        uid: config.uid,
      }));
    }
    return {
      result: result,
      $status: $status
    };
  },
  hooks: {
    on_action: function({config}) {
      if (config.uid == null) {
        config.uid = config.username;
      }
      delete config.username;
      if (config.attributes) {
        if (typeof config.attributes.mail === 'string') {
          return config.attributes.mail = [config.attributes.mail];
        }
      }
    }
  },
  metadata: {
    definitions: definitions
  }
};
