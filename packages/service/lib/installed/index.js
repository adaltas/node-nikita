// Dependencies
import dedent from "dedent";
import utils from "@nikitajs/core/utils";
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function ({ config, parent: { state }, tools: { log } }) {
    let packages = config.cache ? state["nikita:service:packages:installed"] : undefined;
    if (packages !== undefined) {
      return {
        packages: packages,
      }
    }
    try {
      ({ data: packages } = await this.execute({
        $shy: true,
        command: dedent`
          if command -v rpm >/dev/null 2>&1; then
            rpm -qa --qf "%{NAME}\n"
          elif command -v pacman >/dev/null 2>&1; then
            pacman -Qqe
          elif command -v apt >/dev/null 2>&1; then
            dpkg -l | grep '^ii' | awk '{print $2}'
          else
            echo "Unsupported Package Manager" >&2
            exit 2
          fi
        `,
        // code: [0, 1],
        format: ({stdout}) => utils.string.lines(stdout),
        stdout_log: false,
      }));
      log("INFO", "Installed packages retrieved");
    } catch (error) {
      if (error.exit_code === 2) {
        throw utils.error(
          "NIKITA_SERVICE_INSTALLED_UNSUPPORTED_PACKAGE_MANAGER",
          "at the moment, rpm (yum, dnf, ...), pacman and dpkg (apt, apt-get, ...) are supported."
        );
      }
      throw error;
    }
    if (config.cache) {
      log("INFO", 'Caching installed packages.');
      state["nikita:service:packages:installed"] = packages;
    }
    if(config.name) {
      return {
        installed: packages.includes(config.name)
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
