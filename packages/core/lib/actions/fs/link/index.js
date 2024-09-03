// Dependencies
import dedent from "dedent";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config, tools: { path } }) {
    // Set default
    config.mode ??= 0o0755;
    // It is possible to have collision if two symlink
    // have the same parent directory
    await this.fs.base.mkdir({
      target: path.dirname(config.target),
      $relax: "NIKITA_FS_MKDIR_TARGET_EEXIST",
    });
    if (config.exec) {
      const exists = await this.call(
        {
          $raw_output: true,
        },
        async function () {
          const { exists } = await this.fs.exists({
            target: config.target,
          });
          if (!exists) {
            return false;
          }
          const { data } = await this.fs.readFile({
            target: config.target,
            encoding: "utf8",
          });
          const exec_command = /exec (.*) \$@/.exec(data)[1];
          return exec_command && exec_command === config.source;
        },
      );
      if (exists) {
        return;
      }
      await this.fs.writeFile({
        target: config.target,
        content: dedent`
          #!/bin/bash
          exec ${config.source} $@
        `,
      });
      await this.fs.base.chmod({
        target: config.target,
        mode: config.mode,
      });
    } else {
      const exists = await this.call(
        {
          $raw_output: true,
        },
        async function () {
          try {
            const { target } = await this.fs.readlink({
              target: config.target,
            });
            if (target === config.source) {
              return true;
            }
            await this.fs.unlink({
              target: config.target,
            });
            return false;
          } catch {
            return false;
          }
        },
      );
      if (exists) {
        return;
      }
      await this.fs.symlink({
        source: config.source,
        target: config.target,
      });
    }
    return true;
  },
  metadata: {
    definitions: definitions,
  },
};
