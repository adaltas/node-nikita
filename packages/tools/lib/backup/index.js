// Dependencies
import dayjs from "dayjs";
import dayjsUtc from "dayjs/plugin/utc.js";
import dayjsTimezone from "dayjs/plugin/timezone.js";
import definitions from "./schema.json" assert { type: "json" };
dayjs.extend(dayjsUtc);
dayjs.extend(dayjsTimezone);

// Action
export default {
  handler: async function ({ config, tools: { log, path } }) {
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
    const compress = config.compress === true ? "tgz" : config.compress;
    if (compress) {
      filename = `${filename}.${compress}`;
    }
    const target = `${config.target}/${config.name}/${filename}`;
    log("INFO", `Source is ${JSON.stringify(config.source)}`);
    log("INFO", `Target is ${JSON.stringify(target)}`);
    await this.fs.mkdir(`${path.dirname(target)}`);
    if (config.source && !config.compress) {
      await this.fs.copy({
        source: `${config.source}`,
        target: `${target}`,
      });
    }
    if (config.source && config.compress) {
      await this.tools.compress({
        format: `${compress}`,
        source: `${config.source}`,
        target: `${target}`,
      });
    }
    if (config.command) {
      await this.execute({
        command: `${config.command} > ${target}`,
      });
    }
    return {
      base_dir: config.target,
      name: config.name,
      filename: filename,
      target: target,
    };
  },
  metadata: {
    definitions: definitions,
  },
};

// ## Dependencies

// [backmeup]: https://github.com/adaltas/node-backmeup
