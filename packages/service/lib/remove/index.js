// Dependencies
import dedent from "dedent";
import utils from "@nikitajs/core/utils";
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function ({ config, parent: { state }, tools: { log } }) {
    const { installed } = await this.service.installed(config.name);
    if (!installed) {
      log("INFO", `Service ${config.name} not installed`);
      return false;
    }
    try {
      log("INFO", `Remove service ${config.name}`);
      const cacheonly = config.cacheonly ? "-C" : "";
      const { $status } = await this.execute({
        command: `
          if command -v yum >/dev/null 2>&1; then
            yum remove -y ${cacheonly} '${config.name}'
          elif command -v pacman >/dev/null 2>&1; then
            pacman --noconfirm -R ${config.name}
          elif command -v apt-get >/dev/null 2>&1; then
            apt-get remove -y ${config.name}
          else
            echo "Unsupported Package Manager: yum, pacman, apt-get supported" >&2
            exit 2
          fi
        `,
        code: [0, 3],
      });
      // Log information
      log(
        $status
          ? {
              message: "Service removed",
              level: "WARN",
            }
          : {
              message: "Service already removed",
              level: "INFO",
            }
      );
    } catch (error) {
      throw utils.error(
        "NIKITA_SERVICE_REMOVE_INVALID_SERVICE",
        `Invalid Service Name: ${config.name}`
      );
    }
    if (config.cache) {
      log("INFO", 'Remove package from cache key in "nikita:service:packages:installed"');
      const packages = state["nikita:service:packages"];
      state["nikita:service:packages:installed"] = packages.splice(
        packages.indexOf(config.name),
        1
      );
    }
  },
  metadata: {
    argument_to_config: "name",
    definitions: definitions,
  },
};
