// Generated by CoffeeScript 2.5.1
// # `nikita.fs.remove`

// Recursively remove files, directories and links. This is a much more aggressive
// version of `unlink` based on the `rm` command.

// ## Callback parameters

// * `err`   
//   Error object if any.   
// * `status`   
//   Value is "true" if files were removed.   

// ## Implementation details

// Files are removed localling using the Unix "rm" utility. Porting [rimraf] over
// SSH would be too slow.

// ## Simple example

// ```js
// const {status} = await nikita.fs.remove('./some/dir')
// console.info(`Directory was removed: ${status}`)
// ```

// ## Removing a directory unless a given file exists

// ```js
// const {status} = await nikita.fs.remove({
//   target: './some/dir',
//   unless_exists: './some/file'
// })
// console.info(`Directory was removed: ${status}`)
// ```

// ## Removing multiple files and directories

// ```js
// const {status} = await nikita.fs.remove([
//   { target: './some/dir', unless_exists: './some/file' },
//   './some/file'
// ])
// console.info(`Directories was removed: ${status}`)
// ```

// ## Hook
var handler, on_action, schema;

on_action = function({config, metadata}) {
  if (metadata.argument != null) {
    // Validate parameters
    config.target = metadata.argument;
  }
  if (config.target == null) {
    config.target = config.source;
  }
  if (config.target == null) {
    throw Error("Missing option: \"target\"");
  }
};

// ## Schema
schema = {
  type: 'object',
  properties: {
    'source': {
      type: 'string',
      description: `Alias for "target".`
    },
    'target': {
      oneOf: [
        {
          type: 'string'
        },
        {
          type: 'array'
        }
      ],
      description: `File, directory or glob (pattern matching based on wildcard
characters).`
    }
  }
};

// ## Handler
handler = async function({
    config,
    tools: {log}
  }) {
  var file, files, i, len, status;
  // Start real work
  ({files} = (await this.fs.glob(config.target)));
  for (i = 0, len = files.length; i < len; i++) {
    file = files[i];
    log({
      message: `Removing file ${file}`,
      level: 'INFO',
      module: 'nikita/lib/fs/remove'
    });
    ({status} = (await this.execute({
      command: `rm -rf '${file}'`
    })));
    if (status) {
      log({
        message: `File ${file} removed`,
        level: 'WARN',
        module: 'nikita/lib/fs/remove'
      });
    }
  }
  return {};
};

// ## Exports
module.exports = {
  handler: handler,
  hooks: {
    on_action: on_action
  },
  metadata: {
    schema: schema
  }
};

// [rimraf]: https://github.com/isaacs/rimraf
