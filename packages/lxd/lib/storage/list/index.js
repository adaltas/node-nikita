// Dependencies
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function() {
    const {data: storages} = await this.lxc.query({
      path: `/1.0/storage-pools?recursion=1`,
    });
    return {
      storages: storages
    };
  },
  metadata: {
    definitions: definitions,
    shy: true
  }
};
