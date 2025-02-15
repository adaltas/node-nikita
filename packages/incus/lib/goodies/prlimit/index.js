// Dependencies
import dedent from "dedent";
import utils from "@nikitajs/incus/utils";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Errors
const errors = {
  NIKITA_LXC_PRLIMIT_MISSING: function () {
    return utils.error("NIKITA_LXC_PRLIMIT_MISSING", [
      "this action requires prlimit installed on the host",
    ]);
  },
};

// Action
export default {
  handler: async function ({ config }) {
    try {
      // TODO: pass sudo as a config instead of inside the command
      const { stdout } = await this.execute({
        command: dedent`
          command -v prlimit || exit 3
          sudo prlimit -p $(incus info ${config.name} | awk '$1=="PID:"{print $2}')
        `,
      });
      const limits = (function () {
        const lines = utils.string.lines(stdout);
        lines.shift();
        const results = [];
        for (const line of lines) {
          const [resource, description, soft, hard, units] = line.split(/\s+/);
          results.push({
            resource: resource,
            description: description,
            soft: soft,
            hard: hard,
            units: units,
          });
        }
        return results;
      })();
      return {
        stdout: stdout,
        limits: limits,
      };
    } catch (error) {
      if (error.exit_code === 3) {
        throw errors.NIKITA_LXC_PRLIMIT_MISSING();
      }
      throw error;
    }
  },
  metadata: {
    definitions: definitions,
    shy: true,
  },
};
