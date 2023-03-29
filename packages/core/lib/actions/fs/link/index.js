// Dependencies
const dedent = require('dedent');
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function ({ config, tools: { path } }) {
    // Set default
    if (config.mode == null) {
      config.mode = 0o0755;
    }
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
          const { exists } = await this.fs.base.exists({
            target: config.target,
          });
          if (!exists) {
            return false;
          }
          const { data } = await this.fs.base.readFile({
            target: config.target,
            encoding: "utf8",
          });
          const exec_command = /exec (.*) \$@/.exec(data)[1];
          return exec_command && exec_command === config.source;
        }
      );
      if (exists) {
        return;
      }
      const content = dedent`
        #!/bin/bash
        exec ${config.source} $@
      `;
      await this.fs.base.writeFile({
        target: config.target,
        content: content,
      });
      await this.fs.base.chmod({
        target: config.target,
        mode: config.mode,
      });
    } else {
      exists = await this.call(
        {
          $raw_output: true,
        },
        async function () {
          try {
            const { target } = await this.fs.base.readlink({
              target: config.target,
            });
            if (target === config.source) {
              return true;
            }
            await this.fs.base.unlink({
              target: config.target,
            });
            return false;
          } catch (error) {
            return false;
          }
        }
      );
      if (exists) {
        return;
      }
      await this.fs.base.symlink({
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
