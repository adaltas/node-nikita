
// Dependencies
import dedent from "dedent";
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function({
    config,
    tools: {log}
  }) {
    if (!(config.pid != null || config.target)) {
      // Validate parameters
      throw Error('Invalid Options: one of pid or target must be provided');
    }
    if ((config.pid != null) && config.target) {
      throw Error('Invalid Options: either pid or target must be provided');
    }
    if (config.pid) {
      const {code} = await this.execute({
        command: `kill -s 0 '${config.pid}' >/dev/null 2>&1 || exit 42`,
        code: [0, 42]
      });
      log(
        "INFO",
        code === 0
          ? `PID ${config.pid} is running`
          : code === 42
          ? `PID ${config.pid} is not running`
          : undefined
      );
      if (code === 0) {
        return {
          running: true
        };
      }
    }
    if (config.target) {
      const {code, stdout} = await this.execute({
        command: dedent`
          [ -f '${config.target}' ] || exit 43
          pid=\`cat '${config.target}'\`
          echo $pid
          if ! kill -s 0 "$pid" >/dev/null 2>&1; then
            rm '${config.target}';
            exit 42;
          fi
        `,
        code: [0, [42, 43]],
        stdout_trim: true
      });
      log('INFO', (function() {
        switch (code) {
          case 0:
            return `PID ${stdout} is running`;
          case 42:
            return `PID ${stdout} is not running`;
          case 43:
            return `PID file ${config.target} does not exists`;
        }
      })());
      if (code === 0) {
        return {
          running: true
        };
      }
    }
    return {
      running: false
    };
  },
  hooks: {
    on_action: function({config}) {
      if (typeof config.pid === 'string') {
        return config.pid = parseInt(config.pid, 10);
      }
    }
  },
  metadata: {
    // raw_output: true
    definitions: definitions
  }
};
