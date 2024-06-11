// Dependencies
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function({config}) {
    const {stdout} = (await this.execute({
      command: ['npm outdated', '--json', config.global ? '--global' : void 0].join(' '),
      code: [0, 1],
      cwd: config.cwd,
      stdout_log: false
    }));
    return {
      packages: JSON.parse(stdout)
    };
  },
  metadata: {
    definitions: definitions,
    shy: true
  }
};
