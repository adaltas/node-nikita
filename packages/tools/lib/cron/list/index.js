// Dependencies
import dedent from "dedent";
import utils from "@nikitajs/tools/utils";
import definitions from "./schema.json" with { type: "json" };

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
      .filter( line => line.length > 0)
      .filter((job) => config.match ? regex.test(job) : true)
      .map( entry => ({
        raw: entry
      }))
    return {
      entries: entries,
    }
  },
  metadata: {
    definitions: definitions,
  },
};
