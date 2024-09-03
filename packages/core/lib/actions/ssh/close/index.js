// Dependencies
import connect from "ssh2-connect";
import utils from "@nikitajs/core/utils";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: function ({ config, siblings }) {
    if (config.ssh == null) {
      config.ssh = siblings
        .map(({ output }) => output?.ssh)
        .find((ssh) => !!ssh);
    }
    if (!config.ssh) {
      throw utils.error("NIKITA_SSH_CLOSE_NO_CONN", [
        "There is no connection to close,",
        "either pass the connection in the `ssh` configuation",
        "or ensure a connection was open in a sibling action",
      ]);
    }
    if (connect.closed(config.ssh)) {
      // Exit if the connection is already close
      return false;
    }
    // Terminate the connection
    return new Promise(function (resolve, reject) {
      config.ssh.end();
      config.ssh.on("error", reject);
      return config.ssh.on("end", function () {
        return resolve(true);
      });
    });
  },
  metadata: {
    definitions: definitions,
  },
};
