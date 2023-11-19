// Dependencies
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function({config}) {
    const {$status} = await this.db.query(config, {
      command: `SELECT 1 FROM pg_namespace WHERE nspname = '${config.schema}';`,
      grep: '1'
    });
    return {
      exists: $status
    };
  },
  metadata: {
    global: 'db',
    definitions: definitions
  }
};
