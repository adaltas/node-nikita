
// Dependencies
const definitions = require("./schema.json");
const dayjs = require('dayjs');
dayjs.extend(require('dayjs/plugin/utc'));
dayjs.extend(require('dayjs/plugin/timezone'));

// Action
module.exports = {
  handler: async function({
    config,
    tools: {log, path}
  }) {
    let filename = dayjs();
    if (config.local) {
      filename = filename.locale(config.locale);
    }
    if (config.timezone) {
      filename = filename.tz(config.timezone);
    } else {
      filename = filename.utc();
    }
    if (config.format) {
      filename = filename.format(config.format);
    } else {
      filename = filename.toISOString();
    }
    const compress = config.compress === true ? 'tgz' : config.compress;
    if (compress) {
      filename = `${filename}.${compress}`;
    }
    const target = `${config.target}/${config.name}/${filename}`;
    log({
      message: `Source is ${JSON.stringify(config.source)}`,
      level: 'INFO'
    });
    log({
      message: `Target is ${JSON.stringify(target)}`,
      level: 'INFO'
    });
    await this.fs.mkdir(`${path.dirname(target)}`);
    if (config.source && !config.compress) {
      await this.fs.copy({
        source: `${config.source}`,
        target: `${target}`
      });
    }
    if (config.source && config.compress) {
      await this.tools.compress({
        format: `${compress}`,
        source: `${config.source}`,
        target: `${target}`
      });
    }
    if (config.command) {
      await this.execute({
        command: `${config.command} > ${target}`
      });
    }
    return {
      base_dir: config.target,
      name: config.name,
      filename: filename,
      target: target
    };
  },
  metadata: {
    definitions: definitions
  }
};

// ## Dependencies

// [backmeup]: https://github.com/adaltas/node-backmeup
