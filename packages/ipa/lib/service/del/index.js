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
    const { $status: exists } = await this.ipa.service.exists({
      $shy: false,
      connection: config.connection,
      principal: config.principal,
    });
    if (!exists) {
      return;
    }
    await this.network.http(config.connection, {
      negotiate: true,
      method: "POST",
      data: {
        method: "service_del/1",
        params: [[config.principal], {}],
        id: 0,
      },
    });
  },
  metadata: {
    definitions: definitions,
  },
};
