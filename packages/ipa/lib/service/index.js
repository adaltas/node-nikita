// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    config.connection.http_headers["Referer"] ??=
      config.connection.referer || config.connection.url;
    const { data } = await this.network.http(config.connection, {
      negotiate: true,
      method: "POST",
      data: {
        method: "service_add/1",
        params: [[config.principal], {}],
        id: 0,
      },
    });
    let status = true;
    if (data.error !== null) {
      if (data.error.code !== 4002) {
        // principal alredy exists
        const error = Error(data.error.message);
        error.code = data.error.code;
        throw error;
      }
      status = false;
    }
    return {
      $status: status,
    };
  },
  metadata: {
    definitions: definitions,
  },
};
