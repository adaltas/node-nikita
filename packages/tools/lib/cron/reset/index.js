// Dependencies
import dedent from "dedent";
import utils from "@nikitajs/tools/utils";
import definitions from "./schema.json" with { type: "json" };

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
