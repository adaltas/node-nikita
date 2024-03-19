// Dependencies
import path from 'node:path'
import dedent from "dedent";
import utils from "@nikitajs/incus/utils";
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function ({ config }) {
    if (!config.source) {
      throw Error("Invalid Option: source is required");
    }
    if (!config.target) {
      throw Error("Invalid Option: target is required");
    }
    const { $status } = await this.incus.running({
      container: config.container,
    });
    const isContainerRunning = $status;
    let isTargetIdentical;
    if ($status) {
      try {
        const { $status } = await this.execute({
          command: dedent`
            # Is open ssl installed on host?
            command -v openssl >/dev/null || exit 2
            # Ensure source is a file
            incus exec ${config.container} -- [ -f "${config.source}" ] || exit 3
            # Get source hash
            sourceDgst=\`cat <<EOF | incus exec ${config.container} -- sh
            # Ensure openssl is available
            command -v openssl >/dev/null || exit 4
            # Source does not exist
            openssl dgst -${config.algo} ${config.source} | sed 's/^.* \\([a-z0-9]*\\)$/\\1/g'
            EOF\`
            targetDgst=\`openssl dgst -${config.algo} ${config.target} | sed 's/^.* \\([a-z0-9]*\\)$/\\1/g'\`
            [ "$sourceDgst" != "$targetDgst" ] || exit 42
          `,
          code: [0, 42],
          trap: true,
        });
        isTargetIdentical = $status;
      } catch (error) {
        if (error.exit_code === 2) {
          throw Error("Invalid Requirement: openssl not installed on host");
        }
        if (error.exit_code === 3) {
          throw Error(
            `Invalid Option: source is not a file, got ${JSON.stringify(
              config.source
            )}`
          );
        }
        if (error.exit_code === 4) {
          throw utils.error("NIKITA_INCUS_FILE_PULL_MISSING_OPENSSL", [
            "the openssl package must be installed in the container",
            "and accessible from the `$PATH`.",
          ]);
        }
      }
    }
    if (!isContainerRunning || isTargetIdentical) {
      // Create recursive directories with create_dirs
      if (config.create_dirs) {
        await this.fs.mkdir(path.dirname(config.target));
      }
      // Obtain target filename from source unless defined
      if (config.target.endsWith("/")) {
        config.target = path.join(config.target, path.basename(config.source));
      }
      // Use incus query to make an api call
      // In this current implementation, file must not be too large
      // since its content is stored in memory
      const { data, $status } = await this.incus.query({
        path: `/1.0/instances/${config.container}/files?path=${config.source}`,
        wait: true,
        format: "string",
      });
      await this.fs.base.writeFile({
        target: config.target,
        content: data,
      });
      return {
        $status: $status,
      };
    }
  },
  metadata: {
    tmpdir: true,
    definitions: definitions,
  },
};
