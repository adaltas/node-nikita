// Dependencies
import { escapeshellarg as esa } from "@nikitajs/utils/string";
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function({config}) {
    const { $status, stdout } = await this.execute({
      command: [
        "incus",
        "query",
        config.wait && "--wait",
        "--request",
        config.request,
        config.data != null && `--data ${esa(config.data)}`,
        config.path,
      ].filter(Boolean).join(" "),
      code: config.code,
    });
    switch (config.format) {
      case 'json':
        if ($status) {
          return {
            data: JSON.parse(stdout)
          };
        } else {
          return {
            data: {}
          };
        }
        break;
      case 'string':
        if ($status) {
          return {
            data: stdout
          };
        } else {
          return {
            data: ""
          };
        }
    }
  },
  metadata: {
    definitions: definitions,
    shy: true
  }
};
