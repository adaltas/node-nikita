// Dependencies
import dedent from 'dedent';
import yaml from 'js-yaml';
import diff from 'object-diff';
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function({config}) {
    // Normalize config
    for (const k in config.properties) {
      const v = config.properties[k];
      if (typeof v === 'string') {
        continue;
      }
      config.properties[k] = v.toString();
    }
    // Check if exists
    const { stdout, code } = await this.execute({
      command: dedent`
        incus storage show ${config.name} && exit 42
        ${[
          "incus",
          "storage",
          "create",
          config.name,
          config.driver,
          ...(function () {
            const results = [];
            for (const key in config.properties) {
              const value = config.properties[key];
              results.push(`${key}='${value.replace("'", "\\'")}'`);
            }
            return results;
          })(),
        ].join(" ")}
      `,
      code: [0, 42],
    });
    if (code !== 42) {
      return;
    }
    // Storage already exists, find the changes
    if (config.properties == null) {
      return;
    }
    const { config: currentProperties } = yaml.load(stdout);
    const changes = diff(currentProperties, config.properties);
    for (const key in changes) {
      const value = changes[key];
      await this.execute({
        command: ['incus', 'storage', 'set', config.name, key, `'${value.replace('\'', '\\\'')}'`].join(' ')
      });
    }
    return {
      $status: Object.keys(changes).length > 0
    };
  },
  metadata: {
    definitions: definitions
  }
};
