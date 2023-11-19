// Dependencies
import utils from "@nikitajs/core/utils";
import definitions from "./schema.json" assert { type: "json" };

// ## Exports
export default {
  handler: async function({config}) {
    const {stdout} = await this.db.query(config, {
      command: '\\dn',
      trim: true
    });
    const schemas = utils.string.lines(stdout).map(function(line) {
      const [name, owner] = line.split('|');
      return {
        name: name,
        owner: owner
      };
    });
    return {
      schemas: schemas
    };
  },
  metadata: {
    argument_to_config: 'database',
    global: 'db',
    definitions: definitions
  }
};
