
// Dependencies
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function({
    config,
  }) {
    return await this.docker.tools.execute({
      command: [
        "exec",
        config.uid &&
          [`-u ${config.uid}`, config.gid && `:${config.gid}`]
            .filter(Boolean)
            .join(""),
        `${config.container} ${config.command}`,
      ]
        .filter(Boolean)
        .join(" "),
      code: config.code,
    });
  },
  metadata: {
    global: 'docker',
    definitions: definitions
  }
};
