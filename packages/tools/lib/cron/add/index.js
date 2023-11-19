// Dependencies
import dedent from "dedent";
import utils from "@nikitajs/tools/utils";
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    const crontab = (() => {
      if (config.user != null) {
        log({
          message: `Using user ${config.user}`,
          level: "DEBUG",
        });
        return `crontab -u ${config.user}`;
      } else {
        log({
          message: "Using default user",
          level: "DEBUG",
        });
        return "crontab";
      }
    })();
    const { stdout } = await this.execute({
      command: `${crontab} -l`,
      code: [0, 1],
    });
    const new_job = `${config.when} ${config.command}`;
    // remove useless last element
    const regex = (function () {
      if (!config.match) {
        return new RegExp(`.* ${utils.regexp.escape(config.command)}`);
      } else if (typeof config.match === "string") {
        return new RegExp(config.match);
      } else if (utils.regexp.is(config.match)) {
        return config.match;
      } else {
        throw Error("Invalid option 'match'");
      }
    })();
    let added = true;
    let modified = false;
    let jobs = utils.string
      .lines(stdout.trim())
      .map((job) => {
        if (regex.test(job)) {
          added = false;
          if (job === new_job) {
            return null; // Found job, stop here
          }
          log({
            message: "Entry has changed",
            level: "WARN",
          });
          utils.diff(job, new_job, config);
          job = new_job;
          modified = true;
        }
        if (!job) {
          return null;
        }
        return job;
      })
      .filter((line) => line !== null);
    if (added) {
      jobs.push(new_job);
      log({
        message: "Job not found in crontab, adding",
        level: "WARN",
      });
    }
    if (!(added || modified)) {
      jobs = null;
    }
    if (!jobs) {
      return {
        $status: false,
      };
    }
    if (config.exec) {
      await this.execute({
        command:
          config.user != null
            ? `su -l ${config.user} -c '${config.command}'`
            : config.command,
      });
    }
    await this.execute({
      command: dedent`
        ${crontab} - <<EOF
        ${jobs ? jobs.join("\n", "\nEOF") : "EOF"}
      `,
    });
  },
  metadata: {
    definitions: definitions,
  },
};
