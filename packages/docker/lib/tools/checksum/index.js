
// Dependencies
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function({
    config,
    tools: {log}
  }) {
    log('DEBUG', `Getting image checksum :${config.image}`);
    // Run `docker images` with the following config:
    // - `--no-trunc`: display full checksum
    // - `--quiet`: discard headers
    const {$status, stdout} = await this.docker.tools.execute({
      command: `images --no-trunc --quiet ${config.image}:${config.tag}`,
    });
    const checksum = stdout === '' ? undefined : stdout.toString().trim();
    if ($status) {
      log('INFO', `Image checksum for ${config.image}: ${checksum}`);
    }
    return {
      $status: $status,
      checksum: checksum
    };
  },
  hooks: {
    on_action: function({config}) {
      if (config.repository) {
        throw Error('Configuration `repository` is deprecated, use `image` instead');
      }
    }
  },
  metadata: {
    definitions: definitions,
    global: "docker",
  }
};
