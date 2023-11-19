
// Dependencies
import dedent from "dedent";
import definitions from "./schema.json" assert { type: "json" };

// ## Exports
export default {
  handler: async function({config}) {
    // Normalize properties
    for (const key in config.properties) {
      const value = config.properties[key];
      if (typeof value === 'string') {
        continue;
      }
      config.properties[key] = value.toString();
    }
    for (const key in config.properties) {
      const value = config.properties[key];
      // Write property
      await this.execute({
        command: dedent`
          dconf read ${key} | grep -x "${value}" && exit 3
          dconf write ${key} "${value}"
        `,
        code: [0, 3]
      });
    }
  },
  metadata: {
    definitions: definitions
  }
};
