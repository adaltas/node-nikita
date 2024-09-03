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
        method: "group_add_member/1",
        params: [[config.cn], config.attributes],
        id: 0,
      },
    });
    if (data.error) {
      const error = Error(data.error.message);
      error.code = data.error.code;
      throw error;
    }
    return {
      $status: true,
      result: data.result.result,
    };
  },
  metadata: {
    definitions: definitions,
  },
};
