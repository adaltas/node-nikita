// Dependencies
import connect from "ssh2-connect";
import fs from "node:fs/promises";
import utils from "@nikitajs/core/utils";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    if (!(config.private_key || config.password || config.private_key_path)) {
      // Validate authentication
      throw utils.error("NIKITA_SSH_OPEN_NO_AUTH_METHOD_FOUND", [
        "unable to authenticate the SSH connection,",
        'one of the "private_key", "password", "private_key_path"',
        "configuration properties must be provided",
      ]);
    }
    // Read private key if option is a path
    if (!config.private_key && !config.password) {
      log("DEBUG", `Read Private Key from: ${config.private_key_path}`);
      const location = await utils.tilde.normalize(config.private_key_path);
      try {
        config.private_key = await fs
          .readFile(location, "ascii")
          .then(({ data }) => data);
      } catch (error) {
        if (error.code === "ENOENT") {
          throw utils.error(
            "NIKITA_SSH_OPEN_PRIVATE_KEY_NOT_FOUND",
            `private key doesnt exists: ${JSON.stringify(location)}`,
          );
        }
        throw error;
      }
    }
    try {
      // Establish connection
      log(
        "DEBUG",
        `Read Private Key: ${JSON.stringify(config.private_key_path)}`,
      );
      const conn = await connect(config);
      log("SSH connection is established");
      return { ssh: conn };
    } catch {
      log("WARN", "SSH connection failed");
      // Continue to bootstrap root access
    }
    // Enable root access
    if (config.root.username) {
      log("Bootstrap Root Access");
      await this.ssh.root(config.root);
    }
    log("DEBUG", "Establish Connection: attempt after enabling root access");
    return {
      ssh: await connect(config),
    };
  },
  hooks: {
    on_action: function ({ config }) {
      config.private_key ??= config.privateKey;
      // Define host from ip
      config.host ??= config.ip;
      // Default root properties
      config.root ??= {};
      config.root.host ??= config.root.ip;
      config.root.host ??= config.host;
      config.root.port ??= config.port;
    },
  },
  metadata: {
    definitions: definitions,
  },
};
