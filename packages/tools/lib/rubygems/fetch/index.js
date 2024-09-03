// Dependencies
import path from "node:path";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    // Get version
    if (!config.version) {
      const { $status, stdout } = await this.execute({
        $shy: true,
        command: `${config.gem_bin} specification ${config.name} version -r | grep '^version' | sed 's/.*: \\(.*\\)$/\\1/'`,
        cwd: config.cwd,
        bash: config.bash,
      });
      if ($status) {
        config.version = stdout.trim();
      }
    }
    config.target = `${config.name}-${config.version}.gem`;
    // Fetch package
    const { $status } = await this.execute({
      command: `${config.gem_bin} fetch ${config.name} -v ${config.version}`,
      cwd: config.cwd,
      bash: config.bash,
    });
    return {
      $status: $status,
      filename: config.target,
      filepath: path.resolve(config.cwd, config.target),
    };
  },
  metadata: {
    global: "ruby",
    definitions: definitions,
  },
};
