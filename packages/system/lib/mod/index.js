// Dependencies
import path from "node:path";
import quote from "regexp-quote";
import dedent from "dedent";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    for (const module in config.modules) {
      const active = config.modules[module];
      config.target ??= `${module}.conf`;
      config.target = path.resolve("/etc/modules-load.d", config.target);
      await this.execute({
        $if: config.load && active,
        command: dedent`
          lsmod | grep ${module} && exit 3
          modprobe ${module}
        `,
        code: [0, 3],
      });
      await this.execute({
        $if: config.load && !active,
        command: dedent`
          lsmod | grep ${module} || exit 3
          modprobe -r ${module}
        `,
        code: [0, 3],
      });
      await this.file({
        $if: config.persist,
        target: config.target,
        match: RegExp(`^${quote(module)}(\\n|$)`, "mg"),
        replace: active ? `${module}\n` : "",
        append: true,
        eof: true,
      });
    }
  },
  hooks: {
    on_action: function ({ config }) {
      if (typeof config.modules === "string") {
        config.modules = {
          [config.modules]: true,
        };
      }
    },
  },
  metadata: {
    definitions: definitions,
    argument_to_config: "modules",
  },
};
