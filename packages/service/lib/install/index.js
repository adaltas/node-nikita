// Dependencies
import dedent from "dedent";
import utils from "@nikitajs/core/utils";
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function ({ config, parent: { state }, tools: { log } }) {
    let packages = {
      // installed: config.cache ? state["nikita:service:packages:installed"] : undefined,
      // installed: config.cache ? state["nikita:service:packages:outdated"] : undefined,
    };
    const cacheonly = config.cacheonly ? "-C" : "";
    for (const i in config.pacman_flags) {
      const flag = config.pacman_flags[i];
      if (/^-/.test(flag)) {
        continue;
      }
      if (flag.length === 1) {
        config.pacman_flags[i] = `-${flag}`;
      }
      if (flag.length > 1) {
        config.pacman_flags[i] = `--${flag}`;
      }
    }
    for (const i in config.yay_flags) {
      const flag = config.yay_flags[i];
      if (/^-/.test(flag)) {
        continue;
      }
      if (flag.length === 1) {
        config.yay_flags[i] = `-${flag}`;
      }
      if (flag.length > 1) {
        config.yay_flags[i] = `--${flag}`;
      }
    }
    // Start real work
    log("INFO", `Install service ${config.name}`);
    // List installed packages
    const installed = packages.installed
      ? packages.installed.includes(config.name)
      : await this.service
          .installed(config.name)
          .then(({ installed }) => installed);
    // List packages waiting for update
    const outdated = packages.outdated
      ? packages.outdated.includes(config.name)
      : await this.service
          .outdated(config.name, { cacheonly: config.cacheonly })
          .then(({ outdated }) => outdated);
    // Install the package
    if (!installed || outdated) {
      try {
        await this.execute({
          command: dedent`
            if command -v yum >/dev/null 2>&1; then
              yum install -y ${cacheonly} ${config.name}
            elif command -v yay >/dev/null 2>&1; then
              yay --noconfirm -S ${config.name} ${config.yay_flags.join(" ")}
            elif command -v pacman >/dev/null 2>&1; then
              pacman --noconfirm -S ${config.name} ${config.pacman_flags.join(" ")}
            elif command -v apt-get >/dev/null 2>&1; then
              env DEBIAN_FRONTEND=noninteractive apt-get install -y ${config.name}
            else
              echo "Unsupported Package Manager: yum, pacman, apt-get supported" >&2
              exit 2
            fi
          `,
          code: config.code,
        });
        log("WARN", `Package \"${config.name}\" is installed`);
      } catch (error) {
        if (error.exit_code === 2) {
          throw Error(
            "Unsupported Package Manager: apt-get, pacman, yay, yum supported"
          );
        }
        throw utils.error(
          "NIKITA_SERVICE_INSTALL",
          ["failed to install package,", `name is ${JSON.stringify(config.name)}`],
        );
      }
    }
    // Enrich installed array with package name unless already there
    if (config.cache) {
      // if(!installed) {
      //   log("DEBUG", 'Update installed packages cache.');
      //   state["nikita:service:packages:installed"].push(config.name);
      // }
      // if(oudated) {
      //   log("DEBUG", 'Update outdated packages cache.');
      //   let pcks = packages.outdated;
      //   pcks = pcks.splice(pcks.indexOf(config.name), 1);
      //   state["nikita:service:packages:outdated"] = pcks;
      // }
    }
  },
  metadata: {
    argument_to_config: "name",
    definitions: definitions,
  },
};
