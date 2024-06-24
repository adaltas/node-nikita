// Dependencies
import path from 'node:path'
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function({config}) {
    if (config.rootdir) {
      config.target = `${path.join(config.rootdir, config.target)}`;
    }
    // Write configuration
    const {data} = await this.fs.readFile({
      target: config.target,
      encoding: 'ascii'
    });
    let status = false;
    const locales = data.split('\n');
    for (const i in locales) {
      const locale = locales[i]
      let match;
      if (match = /^#([\w_\-\.]+)($| .+$)/.exec(locale)) {
        if (config.locales.includes(match[1]) === true) {
          locales[i] = match[1] + match[2];
          status = true;
        }
      }
      if (match = /^([\w_\-\.]+)($| .+$)/.exec(locale)) {
        if (config.locales.includes(match[1]) === false) {
          locales[i] = '#' + match[1] + match[2];
          status = true;
        }
      }
    }
    if (status) {
      await this.fs.writeFile({
        target: config.target,
        content: locales.join('\n')
      });
    }
    // Reload configuration
    await this.execute({
      $if: config.generate != null ? config.generate : status,
      rootdir: config.rootdir,
      command: "locale-gen"
    });
    return {
      $status: status || config.generate
    };
  },
  metadata: {
    definitions: definitions
  }
};
