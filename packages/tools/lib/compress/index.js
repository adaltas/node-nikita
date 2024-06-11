

// Dependencies
import definitions from "./schema.json" with { type: "json" };

/**
## Extention to type

Convert a full path, a filename or an extension into a supported compression 
type.
*/
const ext_to_type = function(name, path) {
  if (/((.+\.)|^\.|^)(tar\.gz|tgz)$/.test(name)) {
    return 'tgz';
  } else if (/((.+\.)|^\.|^)tar$/.test(name)) {
    return 'tar';
  } else if (/((.+\.)|^\.|^)zip$/.test(name)) {
    return 'zip';
  } else if (/((.+\.)|^\.|^)bz2$/.test(name)) {
    return 'bz2';
  } else if (/((.+\.)|^\.|^)xz$/.test(name)) {
    return 'xz';
  } else {
    throw Error(`Unsupported Extension: ${JSON.stringify(path.extname(name))}`);
  }
};

// Action
export default {
  handler: async function({
    config,
    tools: {path}
  }) {
    config.source = path.normalize(config.source);
    config.target = path.normalize(config.target);
    const dir = path.dirname(config.source);
    const name = path.basename(config.source);
    // Deal with format option
    const format = config.format || ext_to_type(config.target, path)
    // Run compression
    const output = await this.execute((() => {
      switch (format) {
        case 'tgz':
          return `tar czf ${config.target} -C ${dir} ${name}`;
        case 'tar':
          return `tar cf  ${config.target} -C ${dir} ${name}`;
        case 'bz2':
          return `tar cjf ${config.target} -C ${dir} ${name}`;
        case 'xz':
          return `tar cJf ${config.target} -C ${dir} ${name}`;
        case 'zip':
          return `(cd ${dir} && zip -r ${config.target} ${name} && cd -)`;
      }
    })());
    await this.fs.remove({
      $if: config.clean,
      target: config.source,
      recursive: true
    });
    return output;
  },
  metadata: {
    definitions: definitions
  },
  tools: {
    ext_to_type: ext_to_type
  }
};
