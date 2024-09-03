// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config, tools: { path } }) {
    // check if file is target is directory
    // detect daemon loader provider to construct target
    if (config.name == null) {
      config.name = path.basename(config.source).split(".")[0];
    }
    if (config.target != null) {
      config.name = path.basename(config.target).split(".service")[0];
    }
    if (config.target == null) {
      config.target = `/etc/init.d/${config.name}`;
    }
    const { loader } = await this.service.discover();
    if (config.loader == null) {
      config.loader = loader;
    }
    // discover loader to put in cache
    const args = {
      backup: config.backup,
      content: config.content,
      context: config.context,
      engine: config.engine,
      gid: config.gid,
      local: config.local,
      mode: config.mode,
      source: config.source,
      target: config.target,
      uid: config.uid,
    };
    await (config.context ? this.file.render(args) : this.file(args));
    if (config.loader === "systemctl") {
      const reload = await this.execute({
        $shy: true,
        command: `systemctl status ${config.name} 2>&1 | egrep '(Reason: No such file or directory)|(Unit ${config.name}.service could not be found)|(${config.name}.service changed on disk)'`,
        code: [0, 1],
      }).then(({ $status }) => $status);
      await this.execute({
        $if: reload,
        command: "systemctl daemon-reload; systemctl reset-failed",
      });
    }
  },
  metadata: {
    definitions: definitions,
  },
};
