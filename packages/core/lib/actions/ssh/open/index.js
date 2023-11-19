// Dependencies
import connect from "ssh2-connect";
import fs from "node:fs/promises";
import utils from "@nikitajs/core/utils";
import definitions from "./schema.json" assert { type: "json" };

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
      log({
        message: `Read Private Key from: ${config.private_key_path}`,
        level: "DEBUG",
      });
      const location = await utils.tilde.normalize(config.private_key_path);
      try {
        ({ data: config.private_key } = await fs.readFile(location, "ascii"));
      } catch (error) {
        if (error.code === "ENOENT") {
          throw Error(`Private key doesnt exists: ${JSON.stringify(location)}`);
        }
        throw error;
      }
    }
    try {
      // Establish connection
      log({
        message: `Read Private Key: ${JSON.stringify(config.private_key_path)}`,
        level: "DEBUG",
      });
      const conn = await connect(config);
      log({
        message: "Connection is established",
        level: "INFO",
      });
      return {
        ssh: conn,
      };
    } catch (error) {
      log({
        message: "Connection failed",
        level: "WARN",
      });
      // Continue to bootstrap root access
    }
    // Enable root access
    if (config.root.username) {
      log({
        message: "Bootstrap Root Access",
        level: "INFO",
      });
      await this.ssh.root(config.root);
    }
    log({
      message: "Establish Connection: attempt after enabling root access",
      level: "DEBUG",
    });
    return await this.call(
      {
        $retry: 3,
      },
      async function () {
        return {
          ssh: await connect(config),
        };
      }
    );
  },
  hooks: {
    on_action: function ({ config }) {
      if (config.private_key == null) {
        config.private_key = config.privateKey;
      }
      // Define host from ip
      if (config.ip && !config.host) {
        config.host = config.ip;
      }
      // Default root properties
      if (config.root == null) {
        config.root = {};
      }
      if (config.root.ip && !config.root.host) {
        config.root.host = config.root.ip;
      }
      if (config.root.host == null) {
        config.root.host = config.host;
      }
      if (config.root.port == null) {
        config.root.port = config.port;
      }
    },
  },
  metadata: {
    definitions: definitions,
  },
};
