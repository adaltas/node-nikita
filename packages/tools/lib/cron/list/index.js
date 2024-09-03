// Dependencies
import utils from "@nikitajs/tools/utils";
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
    const { stdout } = await this.execute({
      command: `${command} -l`,
      code: [0, 1],
    });
    // remove useless last element
    const regex = (function () {
      if (!config.match) {
        return undefined;
      } else if (typeof config.match === "string") {
        return new RegExp(config.match);
      } else if (utils.regexp.is(config.match)) {
        return config.match;
      } else {
        throw Error("Invalid option 'match'");
      }
    })();
    let entries = utils.string
      .lines(stdout.trim())
      .filter((line) => line.length > 0)
      .filter((job) => (config.match ? regex.test(job) : true))
      .map((entry) => ({
        raw: entry,
      }));
    return {
      entries: entries,
    };
  },
  metadata: {
    definitions: definitions,
  },
};
