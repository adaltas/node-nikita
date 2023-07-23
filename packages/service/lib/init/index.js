// Dependencies
const definitions = require("./schema.json");

// Action
module.exports = {
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
    const { loader } = await this.service.discover({});
    if (config.loader == null) {
      config.loader = loader;
    }
    // discover loader to put in cache
    await this.file.render({
      target: config.target,
      source: config.source,
      mode: config.mode,
      uid: config.uid,
      gid: config.gid,
      backup: config.backup,
      context: config.context,
      local: config.local,
      engine: config.engine,
    });
    if (config.loader !== "systemctl") {
      return;
    }
    const { $status } = await this.execute({
      $shy: true,
      command: `systemctl status ${config.name} 2>\&1 | egrep '(Reason: No such file or directory)|(Unit ${config.name}.service could not be found)|(${config.name}.service changed on disk)'`,
      code: [0, 1],
    });
    if (!$status) {
      return;
    }
    return await this.execute({
      command: "systemctl daemon-reload; systemctl reset-failed",
    });
  },
  metadata: {
    definitions: definitions,
  },
};
