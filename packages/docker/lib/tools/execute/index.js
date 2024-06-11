
// Dependencies
import dedent from "dedent";
import utils from "@nikitajs/docker/utils";
import { escapeshellarg as esa } from "@nikitajs/core/utils/string";
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function ({ config, tools: { find } }) {
    // Build Docker
    config.opts = Object.keys(config.opts)
      .filter((opt) => config.opts[opt] != null)
      .map((opt) => {
        let val = config.opts[opt];
        if (val === true) {
          val = "true";
        }
        if (val === false) {
          val = "false";
        }
        if (["tlsverify", "debug"].includes(opt)) {
          if(val === "true"){
            return `${esa('--'+opt)}`;
          }
        } else {
          return `${esa('--'+opt)}=${esa(val)}`;
        }
      })
      .join(" ");
    try {
      return await this.execute({
        code: config.code,
        format: config.format,
        trap: true,
        command: [
          config.docker_host && `export DOCKER_HOST=${config.docker_host}`,
          config.machine &&
            dedent`
              if command -v docker-machine ; then echo 1; fi
              machine='${config.machine || ""}'
              if [ -z "${config.machine || ""}" ]; then exit 5; fi
              if docker-machine status "\${machine}" | egrep 'Stopped|Saved'; then
                docker-machine start "\${machine}";
              fi
              eval "$(docker-machine env \${machine})"
            `,
          config.compose
            ? dedent`
              opts='${config.opts}'
              bin=\`command -v docker-compose >/dev/null 2>&1  && echo "docker-compose $opts" || echo "docker $opts compose"\` 
              $bin ${config.command}
            `
            : `docker ${config.opts} ${config.command}`,
        ]
          .filter(Boolean)
          .join("\n"),
      });
    } catch (error) {
      if (utils.string.lines(error.stderr.trim()).length === 1) {
        throw Error(error.stderr.trim());
      }
      if (/^Error response from daemon/.test(error.stderr)) {
        throw Error(
          error.stderr.trim().replace("Error response from daemon: ", "")
        );
      }
      throw error
    }
  },
  metadata: {
    argument_to_config: "command",
    definitions: definitions,
    global: "docker",
  },
};
