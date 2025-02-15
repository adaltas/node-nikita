// Dependencies
import utils from "@nikitajs/core/utils";
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
    const containers = await this.docker.tools
      .execute({
        format: "jsonlines",
        command: [
          "ps",
          "--format '{{json .}}'",
          config.all && "--all",
          ...Object.keys(config.filters || []).map((property) => {
            const value = config.filters[property];
            if (typeof value === "string") {
              return "--filter " + esa(property) + "=" + esa(value);
            } else if (typeof value === "boolean") {
              return (
                "--filter " +
                esa(property) +
                "=" +
                esa(value ? "true" : "false")
              );
            } else {
              throw utils.error("NIKITA_DOCKER_CONTAINERS_FILTER", [
                "Unsupported filter value type,",
                "expect a string or a boolean value,",
                "got ${JSON.stringify(property)}.",
              ]);
            }
          }),
        ]
          .filter(Boolean)
          .join(" "),
      })
      .then(({ data }) => data);
    return {
      count: containers.length,
      containers: containers,
      names: containers.map((c) => c.Names),
    };
  },
  metadata: {
    shy: true,
    definitions: definitions,
  },
};
