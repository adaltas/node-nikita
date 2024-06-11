
// Dependencies
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function({
    config,
    tools: {log}
  }) {
    const {$status} = await this.docker.tools.status({
      container: config.container,
      $shy: true
    });
    if ($status) {
      log(`Container already started ${config.container} (Skipping)`);
    } else {
      log(`Starting container ${config.container}`);
    }
    await this.docker.tools.execute({
      $unless: $status,
      command: ["start", config.attach && "-a", `${config.container}`]
        .filter(Boolean)
        .join(" "),
    });
  },
  metadata: {
    global: 'docker',
    definitions: definitions
  }
};
