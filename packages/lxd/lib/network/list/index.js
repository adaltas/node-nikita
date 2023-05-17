// Dependencies
const definitions = require("./schema.json");

// Action
module.exports = {
  handler: async function () {
    const { data } = await this.lxc.query({
      path: "/1.0/networks",
    });
    return {
      $status: true,
      list: data.map(line => line.split('/').pop())
    };
  },
  metadata: {
    definitions: definitions,
    shy: true,
  },
};
