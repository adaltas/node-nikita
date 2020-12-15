// Generated by CoffeeScript 2.5.1
// # `nikita.tools.extract`

// Extract an archive. Multiple compression types are supported. Unless
// specified as an option, format is derived from the source extension. At the
// moment, supported extensions are '.tgz', '.tar.gz', tar.bz2, 'tar.xz' and '.zip'.

// ## Callback parameters

// * `err`   
//   Error object if any.   
// * `status`   
//   Value is "true" if archive was extracted.   

// ## Example

// ```js
// const {status} = await nikita.tools.extract({
//   source: '/path/to/file.tgz'
//   destation: '/tmp'
// })
// console.info(`File was extracted: ${status}`)
// ```

// ## Hooks
var handler, on_action, schema, utils;

on_action = function({config}) {
  if (config.preserve_permissions != null) {
    config.preserve_mode = config.preserve_permissions;
    return console.warn('Deprecated property: "preserve_permissions" is renamed "preserve_mode"');
  }
};

// ## Schema
schema = {
  type: 'object',
  properties: {
    'creates': {
      type: 'string',
      description: `Ensure the given file is created or an error is send in the callback.`
    },
    'format': {
      type: 'string',
      description: `One of 'tgz', 'tar', 'xz', 'bz2' or 'zip'.`
    },
    'preserve_owner': {
      type: 'boolean',
      description: `Preserve ownership when extracting. True by default if runned as root,
else false.`
    },
    'preserve_mode': {
      type: 'boolean',
      description: `Preserve permissions when extracting. True by default if runned as
root, else false.`
    },
    'source': {
      type: 'string',
      description: `Archive to decompress.`
    },
    'strip': {
      type: 'number',
      description: `Remove the specified number of leading path elements. Apply only to
tar(s) formats.`
    },
    'target': {
      type: 'string',
      description: `Default to the source parent directory.`
    }
  },
  required: ['source']
};

// ## Handler
handler = async function({
    config,
    tools: {log, path}
  }) {
  var command, ext, format, ouptut, ref, stats, tar_opts, target;
  // Validate config
  target = (ref = config.target) != null ? ref : path.dirname(config.source);
  tar_opts = [];
  // If undefined, we do not apply flag. Default behaviour depends on the user
  if (config.preserve_owner === true) {
    tar_opts.push('--same-owner');
  } else if (config.preserve_owner === false) {
    tar_opts.push('--no-same-owner');
  }
  if (config.preserve_mode === true) {
    tar_opts.push('-p');
  } else if (config.preserve_mode === false) {
    tar_opts.push('--no-same-permissions');
  }
  if (typeof config.strip === 'number') {
    tar_opts.push(`--strip-components ${config.strip}`);
  }
  // Deal with format option
  if (config.format != null) {
    format = config.format;
  } else {
    if (/\.(tar\.gz|tgz)$/.test(config.source)) {
      format = 'tgz';
    } else if (/\.tar$/.test(config.source)) {
      format = 'tar';
    } else if (/\.zip$/.test(config.source)) {
      format = 'zip';
    } else if (/\.tar\.bz2$/.test(config.source)) {
      format = 'bz2';
    } else if (/\.tar\.xz$/.test(config.source)) {
      format = 'xz';
    } else {
      ext = path.extname(config.source);
      throw Error(`Unsupported extension, got ${JSON.stringify(ext)}`);
    }
  }
  // Stat the source file
  ({stats} = (await this.fs.base.stat({
    target: config.source
  })));
  if (!utils.stats.isFile(stats.mode)) {
    throw Error(`Not a File: ${config.source}`);
  }
  // Extract the source archive
  command = null;
  log({
    message: `Format is ${format}`,
    level: 'DEBUG',
    module: 'nikita/lib/tools/extract'
  });
  switch (format) {
    case 'tgz':
      command = `tar xzf ${config.source} -C ${target} ${tar_opts.join(' ')}`;
      break;
    case 'tar':
      command = `tar xf ${config.source} -C ${target} ${tar_opts.join(' ')}`;
      break;
    case 'bz2':
      command = `tar xjf ${config.source} -C ${target} ${tar_opts.join(' ')}`;
      break;
    case 'xz':
      command = `tar xJf ${config.source} -C ${target} ${tar_opts.join(' ')}`;
      break;
    case 'zip':
      command = `unzip -u ${config.source} -d ${target}`;
  }
  ouptut = (await this.execute({
    command: command
  }));
  // Assert the target creation
  if (config.creates) {
    await this.fs.assert({
      target: config.creates
    });
  }
  return ouptut;
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

// ## Dependencies
utils = require('./utils');
