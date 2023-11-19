
// Dependencies
import definitions from "./schema.json" assert { type: "json" };
import utils from "@nikitajs/tools/utils";

// Action
export default {
  handler: async function({
    config,
    tools: {log, path}
  }) {
    // Validate config
    const target = config.target || path.dirname(config.source);
    const tar_opts = [];
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
    let format = config.format;
    if (config.format == null) {
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
        throw Error(
          `Unsupported extension, got ${JSON.stringify(
            path.extname(config.source)
          )}`
        );
      }
    }
    // Stat the source file
    const {stats} = (await this.fs.base.stat({
      target: config.source
    }));
    if (!utils.stats.isFile(stats.mode)) {
      throw Error(`Not a File: ${config.source}`);
    }
    // Extract the source archive
    log({
      message: `Format is ${format}`,
      level: 'DEBUG'
    });
    let command;
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
    const ouptut = await this.execute({
      command: command
    });
    // Assert the target creation
    if (config.creates) {
      await this.fs.assert({
        target: config.creates
      });
    }
    return ouptut;
  },
  hooks: {
    on_action: function({config}) {
      if (config.preserve_permissions != null) {
        config.preserve_mode = config.preserve_permissions;
        return console.warn('Deprecated property: "preserve_permissions" is renamed "preserve_mode"');
      }
    }
  },
  metadata: {
    definitions: definitions
  }
};
