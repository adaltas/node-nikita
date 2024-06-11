
// Dependencies
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function({config}) {
    const {$status} = await this.docker.tools.execute({
      command: `ps | egrep ' ${config.container}$' | grep 'Up'`,
      code: [0, 1]
    });
    await this.docker.tools.execute({
      $if: $status,
      command: [
        "kill",
        config.signal != null && `-s ${config.signal}`,
        `${config.container}`,
      ]
        .filter(Boolean)
        .join(" "),
    });
  },
  metadata: {
    global: 'docker',
    definitions: definitions
  }
};
