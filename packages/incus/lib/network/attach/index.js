// Dependencies
import dedent from "dedent";
import { escapeshellarg as esa } from "@nikitajs/utils/string";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    //Build command
    const { exists } = await this.incus.config.device.exists({
      container: config.container,
      device: config.name,
    });
    if (exists) return false;
    // const { data } = await this.incus.info(config.container);
    // const res = await this.incus.query({
    //   path: `/1.0/instances/${config.container}`,
    //   request: "PUT",
    //   data: {
    //     devices: {
    //       ...data.devices,
    //       [config.name]: {
    //         network: config.name,
    //         type: "nic",
    //       },
    //     },
    //   },
    // });
    // console.log(res);
    return await this.execute({
      command: [
        "incus",
        "network",
        "attach",
        esa(config.name),
        esa(config.container),
      ].join(" "),
    });
  },
  metadata: {
    definitions: definitions,
  },
};
