// Dependencies
import dedent from "dedent";
import utils from "@nikitajs/tools/utils";
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function({
    config,
    tools: {log}
  }) {
    const command = config.user ? `crontab -u ${config.user}` : "crontab";
    let status = false;
    const {stdout, stderr} = (await this.execute({
      $shy: true,
      command: `${command} -l`
    }));
    if (/^no crontab for/.test(stderr)) {
      throw Error('User crontab not found');
    }
    let myjob = config.when ? utils.regexp.escape(config.when) : '.*';
    myjob += utils.regexp.escape(` ${config.command}`);
    let regex = new RegExp(myjob);
    const jobs = stdout.trim().split('\n');
    for (const i in jobs) {
      const job = jobs[i];
      if (!regex.test(job)) {
        continue;
      }
      log({
        message: `Job '${job}' matches. Removing from list`,
        level: 'WARN'
      });
      status = true;
      jobs.splice(i, 1);
    }
    log({
      message: "No Job matches. Skipping",
      level: 'INFO'
    });
    if (!status) {
      return;
    }
    await this.execute({
      command: dedent`
      ${command} - <<EOF
      ${jobs ? jobs.join('\n', '\nEOF') : 'EOF'}
      `
    });
  },
  metadata: {
    definitions: definitions
  }
};
