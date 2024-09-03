// Dependencies
import path from "node:path";
import dedent from "dedent";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    if (config.rootdir) {
      // Configs
      config.target = `${path.join(config.rootdir, config.target)}`;
    }
    if (Array.isArray(config.content.DNS)) {
      config.content.DNS = config.content.DNS.join(" ");
    }
    if (Array.isArray(config.content.FallbackDNS)) {
      config.content.FallbackDNS = config.content.FallbackDNS.join(" ");
    }
    if (Array.isArray(config.content.Domains)) {
      config.content.Domains = config.content.Domains.join(" ");
    }
    // Write configuration
    const { $status } = await this.file.ini({
      separator: "=",
      target: config.target,
      content: {
        Resolve: config.content,
      },
      merge: config.merge,
    });
    await this.execute({
      $if: config.reload != null ? config.reload : $status,
      sudo: true,
      command: dedent`
        systemctl daemon-reload
        systemctl restart systemd-resolved
      `,
      trap: true,
    });
  },
  metadata: {
    definitions: definitions,
  },
};
