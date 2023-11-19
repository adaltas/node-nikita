
// Dependencies
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function({config}) {
    const {$status} = await this.docker.tools.execute({
      $if: config.name,
      $shy: true,
      command: `volume inspect ${config.name}`,
      code: [1, 0]
    });
    await this.docker.tools.execute({
      $if: !config.name || $status,
      command: ["volume create", config.driver ? `--driver ${config.driver}` : void 0, config.label ? `--label ${config.label.join(',')}` : void 0, config.name ? `--name ${config.name}` : void 0, config.opt ? `--opt ${config.opt.join(',')}` : void 0].join(' ')
    });
  },
  metadata: {
    global: 'docker',
    definitions: definitions
  }
};
