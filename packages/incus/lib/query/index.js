// Dependencies
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
    const path = [
      config.path,
      Object.keys(config.path).length && "?",
      new URLSearchParams(config.query),
    ]
      .filter(Boolean)
      .join("");
    const { $status, stdout } = await this.execute({
      command: [
        "incus",
        "query",
        config.wait && "--wait",
        "--request",
        config.request,
        config.data != null && `--data ${esa(JSON.stringify(config.data))}`,
        path,
      ]
        .filter(Boolean)
        .join(" "),
      code: config.code,
    });
    switch (config.format) {
      case "json":
        if ($status) {
          return {
            data: JSON.parse(stdout || "{}"),
          };
        } else {
          return {
            data: {},
          };
        }
      case "string":
        if ($status) {
          return {
            data: stdout,
          };
        } else {
          return {
            data: "",
          };
        }
    }
  },
  metadata: {
    definitions: definitions,
    shy: true,
  },
};
