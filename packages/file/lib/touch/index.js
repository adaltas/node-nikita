// Dependencies
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    const { $status } = await this.call(async function () {
      log({
        message: `Check if target exists \"${config.target}\"`,
        level: "DEBUG",
      });
      const { exists } = await this.fs.base.exists({
        target: config.target,
      });
      if (!exists) {
        log({
          message: "Destination does not exists",
          level: "INFO",
        });
      }
      return !exists;
    });
    // if the file doesn't exist, create a new one
    if ($status) {
      await this.file({
        content: "",
        target: config.target,
        mode: config.mode,
        uid: config.uid,
        gid: config.gid,
      });
    } else {
      // todo check uid/gid/mode
      // if the file exists, overwrite it using `touch` but don't update the status
      await this.execute({
        $shy: true,
        command: `touch ${config.target}`,
      });
    }
  },
  metadata: {
    argument_to_config: "target",
    definitions: definitions,
  },
};
