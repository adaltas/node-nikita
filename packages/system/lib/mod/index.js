
// Dependencies
import path from 'node:path'
import quote from "regexp-quote";
import dedent from "dedent";
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function({metadata, config}) {
    for (const module in config.modules) {
      const active = config.modules[module];
      let target = config.target;
      if (target == null) {
        target = `${module}.conf`;
      }
      target = path.resolve('/etc/modules-load.d', target);
      await this.execute({
        $if: config.load && active,
        command: dedent`
          lsmod | grep ${module} && exit 3
          modprobe ${module}
        `,
        code: [0, 3]
      });
      await this.execute({
        $if: config.load && !active,
        command: dedent`
          lsmod | grep ${module} || exit 3
          modprobe -r ${module}
        `,
        code: [0, 3]
      });
      await this.file({
        $if: config.persist,
        target: target,
        match: RegExp(`^${quote(module)}(\\n|$)`, "mg"),
        replace: active ? `${module}\n` : '',
        append: true,
        eof: true
      });
    }
  },
  hooks: {
    on_action: function({config}) {
      if (typeof config.modules === 'string') {
        config.modules = {
          [config.modules]: true
        };
      }
    }
  },
  metadata: {
    definitions: definitions,
    argument_to_config: 'modules'
  }
};
