// Dependencies
const utils = require("../../utils");
const definitions = require("./schema.json");

// Action
module.exports = {
  handler: async function ({ config }) {
    const { stdout } = await this.execute({
      command: `df --output='${config.output.join(",")}'`,
    });
    const disks = utils.string
      .lines(stdout)
      .filter((line, i) => i !== 0 && !/^\s*$/.test(line))
      .map((line) => {
        const record = line.split(/\s+/);
        const disk = {
          df: {},
        };
        for (const i in config.output) {
          const property = config.output[i];
          disk.df[property] = record[i];
        }
        disk.filesystem = disk.df.source;
        disk.total = disk.df.itotal * 1024;
        disk.used = disk.df.iused * 1024;
        disk.available = disk.df.avail * 1024;
        disk.available_pourcent = disk.df.pcent;
        disk.mountpoint = disk.df.target;
        return disk;
      });
    return {
      disks: disks,
    };
  },
  metadata: {
    definitions: definitions,
    shy: true,
  },
};
