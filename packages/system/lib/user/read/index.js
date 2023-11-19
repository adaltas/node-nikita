// Dependencies
import utils from "@nikitajs/system/utils";
import definitions from "./schema.json" assert { type: "json" };

// Parse the passwd output
const str2passwd = function (data) {
  const passwd = {};
  for (const line of utils.string.lines(data)) {
    const record = /(.*)\:\w\:(.*)\:(.*)\:(.*)\:(.*)\:(.*)/.exec(line);
    if (!record) {
      continue;
    }
    passwd[record[1]] = {
      user: record[1],
      uid: parseInt(record[2]),
      gid: parseInt(record[3]),
      comment: record[4],
      home: record[5],
      shell: record[6],
    };
  }
  return passwd;
};

// Action
export default {
  handler: async function ({ config }) {
    if (typeof config.uid === "string" && /\d+/.test(config.uid)) {
      config.uid = parseInt(config.uid, 10);
    }
    // Fetch the users information
    let passwd;
    if (config.target) {
      ({ data: passwd } = await this.fs.base.readFile({
        target: config.target,
        encoding: "ascii",
        format: ({ data }) => str2passwd(data),
      }));
    } else {
      ({ data: passwd } = await this.execute({
        command: "getent passwd",
        format: ({ stdout }) => str2passwd(stdout),
      }));
    }
    if (!config.uid) {
      return {
        // Return all the users
        users: passwd,
      };
    }
    // Return a user by username
    if (typeof config.uid === "string") {
      const user = passwd[config.uid];
      if (!user) {
        throw Error(
          `Invalid Option: no uid matching ${JSON.stringify(config.uid)}`
        );
      }
      return {
        user: user,
      };
    } else {
      // Return a user by uid
      const user = Object.values(passwd).filter(function (user) {
        return user.uid === config.uid;
      })[0];
      if (!user) {
        throw Error(
          `Invalid Option: no uid matching ${JSON.stringify(config.uid)}`
        );
      }
      return {
        user: user,
      };
    }
  },
  metadata: {
    definitions: definitions,
    shy: true,
  },
};
