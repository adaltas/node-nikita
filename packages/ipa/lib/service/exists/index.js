
// Dependencies
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function({config}) {
    config.connection.http_headers['Referer'] ??= config.connection.referer || config.connection.url;
    try {
      await this.ipa.service.show({
        connection: config.connection,
        principal: config.principal
      });
      return {
        $status: true,
        exists: true
      };
    } catch (error) {
      if (error.code !== 4001) { // service not found
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
