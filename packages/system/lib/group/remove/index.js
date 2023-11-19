
// Dependencies
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: function({metadata, config}) {
    this.execute({
      command: `groupdel ${config.name}`,
      code: [0, 6]
    });
  },
  metadata: {
    argument_to_config: 'name',
    definitions: definitions
  }
};
