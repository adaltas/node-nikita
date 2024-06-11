
// Dependencies
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: function({config}) {
    this.execute({
      command: `userdel ${config.name}`,
      code: [0, 6]
    });
  },
  metadata: {
    argument_to_config: 'name'
  },
  definitions: definitions
};
