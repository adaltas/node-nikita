// Dependencies
import dedent from "dedent";
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function({config}) {
    return (await this.execute({
      command: dedent`
        incus info ${config.container} > /dev/null || exit 42
        ${['incus', 'delete', config.container, config.force ? "--force" : void 0].join(' ')}
      `,
      code: [0, 42]
    }));
  },
  metadata: {
    argument_to_config: 'container',
    definitions: definitions
  }
};
