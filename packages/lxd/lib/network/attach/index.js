// Dependencies
import dedent from "dedent";
import { escapeshellarg as esa } from "@nikitajs/core/utils/string";
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function({config}) {
    //Build command
    const command_attach = [
      "lxc",
      "network",
      "attach",
      esa(config.network),
      esa(config.container),
    ].join(" ");
    //Execute
    return (await this.execute({
      command: dedent`
        lxc config device list ${esa(config.container)} | grep ${esa(config.network)} && exit 42
        ${command_attach}
      `,
      code: [0, 42]
    }));
  },
  metadata: {
    definitions: definitions
  }
};
