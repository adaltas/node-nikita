// Dependencies
import utils from "@nikitajs/utils";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    const { data } = await this.incus
      .query({
        path: `/1.0/networks/${config.name}`,
      })
      .catch(() => {
        throw utils.error("NIKITA_INCUS_NETWORK_SHOW_NOT_EXIST", [
          `failed to retrieve network information,`,
          `the network ${config.name} does not exists`,
          `or an unexpected error occured.`,
        ]);
      });
    return { data };
  },
  metadata: {
    argument_to_config: "name",
    definitions: definitions,
    shy: true,
  },
};
