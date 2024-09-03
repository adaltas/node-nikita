// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    const command = config.user ? `crontab -u ${config.user}` : "crontab";
    const { entries } = await this.tools.cron.list({
      user: config.user,
    });
    if (entries.length === 0) {
      return false;
    }
    await this.execute({
      command: `${command} -r`,
    });
    return true;
  },
  metadata: {
    definitions: definitions,
  },
};
