// Dependencies
import utils from "@nikitajs/system/utils";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Parse the groups output
const str2groups = function (data) {
  const groups = {};
  for (const line of utils.string.lines(data)) {
    const group = /(.*):(.*):(.*):(.*)/.exec(line);
    if (!group) {
      continue;
    }
    groups[group[1]] = {
      group: group[1],
      password: group[2],
      gid: parseInt(group[3]),
      users: group[4] ? group[4].split(",") : [],
    };
  }
  return groups;
};

// Action
export default {
  handler: async function ({ config }) {
    if (typeof config.gid === "string" && /\d+/.test(config.gid)) {
      config.gid = parseInt(config.gid, 10);
    }
    // Fetch the groups information
    let groups;
    if (!config.target) {
      const { stdout } = await this.execute({
        command: "getent group",
      });
      groups = str2groups(stdout);
    } else {
      const { data } = await this.fs.readFile({
        target: config.target,
        encoding: "ascii",
      });
      groups = str2groups(data);
    }
    if (!config.gid) {
      // Return all the groups
      return {
        groups: groups,
      };
    }
    // Return a group by name
    if (typeof config.gid === "string") {
      const group = groups[config.gid];
      if (!group) {
        throw Error(
          `Invalid Option: no gid matching ${JSON.stringify(config.gid)}`,
        );
      }
      return {
        group: group,
      };
    } else {
      // Return a group by gid
      const group = Object.values(groups).find(
        (group) => group.gid === config.gid,
      );
      if (!group) {
        throw Error(
          `Invalid Option: no gid matching ${JSON.stringify(config.gid)}`,
        );
      }
      return {
        group: group,
      };
    }
  },
  metadata: {
    definitions: definitions,
  },
};
