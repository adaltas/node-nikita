
// Dependencies
import dedent from "dedent";
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function({config}) {
    if (config.gem_bin == null) {
      config.gem_bin = 'gem';
    }
    const version = config.version ? `-v ${config.version}` : '-a';
    await this.execute({
      command: dedent`
        ${config.gem_bin} list -i ${config.name} || exit 3
        ${config.gem_bin} uninstall ${config.name} ${version}
      `,
      code: [0, 3],
      bash: config.bash
    });
  },
  metadata: {
    global: 'ruby',
    definitions: definitions
  }
};
