// Dependencies
const dedent = require('dedent');
const utils = require('../../utils');
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function({
    config,
    tools: {log}
  }) {
    const crontab = ( () => {
      if (config.user != null) {
        log({
          message: `Using user ${config.user}`,
          level: 'INFO'
        });
        return `crontab -u ${config.user}`;
      } else {
        log({
          message: "Using default user",
          level: 'INFO'
        });
        return "crontab";
      }
    })();
    let status = false;
    const {stdout, stderr} = (await this.execute({
      $shy: true,
      command: `${crontab} -l`
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
      ${crontab} - <<EOF
      ${jobs ? jobs.join('\n', '\nEOF') : 'EOF'}
      `
    });
  },
  metadata: {
    definitions: definitions
  }
};
