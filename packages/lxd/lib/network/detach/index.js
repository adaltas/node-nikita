// Dependencies
import dedent from "dedent";
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function({config}) {
    const {$status} = await this.execute({
      command: dedent`
        lxc config device list ${config.container} | grep ${config.network} || exit 42
        ${['lxc', 'network', 'detach', config.network, config.container].join(' ')}
      `,
      code: [0, 42]
    });
    return $status
  },
  metadata: {
    definitions: definitions
  }
};
