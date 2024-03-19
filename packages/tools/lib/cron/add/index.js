// Dependencies
import dedent from "dedent";
import utils from "@nikitajs/tools/utils";
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    const command = config.user ? `crontab -u ${config.user}` : "crontab";
    // console.log(await this.tools.cron.list().then(({ entries }) => entries))
    const entries = await this.tools.cron.list()
      .then(({ entries }) => entries.map(({ raw }) => raw));
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
    let diff;
    let jobs = entries
      .map((job) => {
        if (regex.test(job)) {
          added = false;
          if (job === new_job) {
            return null; // Found job, stop here
          }
          log("WARN", "Entry has changed");
          // console.log('>', job, new_job, config)
          // console.log('<', utils.diff(job, new_job, config));
          ({ raw: diff } = utils.diff(job, new_job, config));
          job = new_job;
          modified = true;
        }
        return job;
      })
      .filter((line) => line !== null);
    if (added) {
      jobs.push(new_job);
      log("WARN", "Job not found in crontab, adding");
    }
    if (!(added || modified)) {
      jobs = null;
    }
    if (!jobs) {
      return {
        $status: false,
      };
    }
    await this.execute({
      command: [
        `${command} - <<EOF`,
        ...jobs,
        'EOF',
      ].join('\n')
    });
    if (config.exec) {
      await this.execute({
        command:
          config.user != null
            ? `su -l ${config.user} -c '${config.command}'`
            : config.command,
      });
    }
    return {
      $status: true,
      diff: diff,
    }
  },
  metadata: {
    definitions: definitions,
  },
};
