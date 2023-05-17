// Dependencies
const path = require('path');
const dedent = require('dedent');
const utils = require('../../utils');
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function ({ config, metadata: { tmpdir } }) {
    // Make source file with content
    if (config.content != null) {
      const tmpfile = path.join(
        tmpdir,
        `nikita.${Date.now()}${Math.round(Math.random() * 1000)}`
      );
      await this.fs.base.writeFile({
        target: tmpfile,
        content: config.content,
      });
      config.source = tmpfile;
    }
    // note, name could be obtained from lxd_target
    // throw Error "Invalid Option: target is required" if not config.target and not config.lxd_target
    if (config.lxd_target == null) {
      config.lxd_target = `${path.join(config.container, config.target)}`;
    }
    const { $status } = await this.lxc.running({
      container: config.container,
    });
    const isContainerRunning = $status;
    let isTargetIdentical;
    if (isContainerRunning) {
      try {
        const {$status} = await this.execute({
          command: dedent`
            # Ensure source is a file
            [ -f "${config.source}" ] || exit 2
            command -v openssl >/dev/null || exit 3
            sourceDgst=\`openssl dgst -${config.algo} ${config.source} | sed 's/^.* \\([a-z0-9]*\\)$/\\1/g'\`
            # Get target hash
            targetDgst=\`cat <<EOF | lxc exec ${config.container} -- sh
            # Ensure openssl is available
            command -v openssl >/dev/null || exit 4
            # Target does not exist
            [ ! -f "${config.target}" ] && exit 0
            openssl dgst -${config.algo} ${config.target} | sed 's/^.* \\([a-z0-9]*\\)$/\\1/g'
            EOF\`
            [ "$sourceDgst" != "$targetDgst" ] || exit 42
          `,
          code: [0, 42],
          trap: true,
        });
        isTargetIdentical = $status
      } catch (error) {
        if (error.exit_code === 2) {
          throw Error(
            `Invalid Option: source is not a file, got ${JSON.stringify(
              config.source
            )}`
          );
        }
        if (error.exit_code === 3) {
          throw Error("Invalid Requirement: openssl not installed on host");
        }
        if (error.exit_code === 4) {
          throw utils.error("NIKITA_LXD_FILE_PUSH_MISSING_OPENSSL", [
            "the openssl package must be installed in the container",
            "and accessible from the `$PATH`.",
          ]);
        }
      }
    }
    let status = false;
    if (!isContainerRunning || isTargetIdentical) {
      await this.execute({
        command: `${[
          "lxc",
          "file",
          "push",
          config.source,
          config.lxd_target,
          config.create_dirs && "--create-dirs",
          typeof config.gid === "number" && "--gid",
          typeof config.uid === "number" && "--uid",
          config.mode && `--mode ${config.mode}`,
        ].filter(Boolean).join(" ")}`,
        trap: true,
        trim: true,
      });
      status = true;
    }
    if (typeof config.gid === "string") {
      await this.lxc.exec({
        container: config.container,
        command: `chgrp ${config.gid} ${config.target}`,
      });
      status = true;
    }
    if (typeof config.uid === "string") {
      await this.lxc.exec({
        container: config.container,
        command: `chown ${config.uid} ${config.target}`,
      });
      status = true;
    }
    return status;
  },
  metadata: {
    tmpdir: true,
    definitions: definitions,
  },
};
