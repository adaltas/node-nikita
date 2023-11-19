// Dependencies
import dedent from "dedent";
import utils from "@nikitajs/core/utils";
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function ({ metadata, config, parent: { state }, tools: { log } }) {
    let packages = config.cache ? state["nikita:service:packages:outdated"] : undefined;
    if (packages !== undefined) {
      return {
        packages: packages,
      }
    }
    const cacheonly = config.cacheonly ? "-C" : "";
    try {
      // Error inside the pipeline are not catched (eg no sudo permission).
      // A possible solution includes breaking the pipeline into multiple calls.
      // Another solution bash-only alternative is to use `set -o pipeline`.
      // See https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html
      // The apt-get is pretty weak, `apt-get -s -u upgrade` can be executed
      // by non-root users but its output will add fake packages to the list
      // due to the presence of indented comments.
      ({ data: packages } = await this.execute({
        $shy: true,
        command: dedent`
          if command -v yum >/dev/null 2>&1; then
            yum ${cacheonly} check-update -q | sed 's/\\([^\\.]*\\).*/\\1/'
          elif command -v pacman >/dev/null 2>&1; then
            pacman -Qu | sed 's/\\([^ ]*\\).*/\\1/'
          elif command -v apt-get >/dev/null 2>&1; then
            apt-get -s -u upgrade | grep '^\s' | sed 's/\\s/\\n/g'
          else
            echo "Unsupported Package Manager" >&2
            exit 2
          fi
        `,
        format: ({ stdout }) =>
          utils.array.flatten(
            utils.string
              .lines(stdout)
              .map((line) => line.split(" ").map(pck => pck.trim()).filter(pck => pck !== ''))
          ),
        stdout_log: false,
      }));
      log("INFO", "Outdated packages retrieved");
    } catch (error) {
      if (error.exit_code === 43) {
        throw utils.error(
          "NIKITA_SERVICE_OUTDATED_UNSUPPORTED_PACKAGE_MANAGER",
          "at the moment, rpm (yum, dnf, ...), pacman and dpkg (apt, apt-get, ...) are supported."
        );
      } else if (error.exit_code === 100) {
        throw utils.error(
          "NIKITA_SERVICE_OUTDATED_SUDO",
          "permission denied, maybe run this command as sudoer or with the `$debug` configuration."
        );
      }
      throw error;
    }
    if (config.cache) {
      log("INFO", 'Caching outdated packages.');
      state["nikita:service:packages:outdated"] = packages;
    }
    if(config.name) {
      return {
        outdated: packages.includes(config.name)
      }
    }else{
      return {
        packages: packages,
      }
    }
  },
  metadata: {
    argument_to_config: "name",
    definitions: definitions,
    metadata: {
      shy: true
    }
  },
};
