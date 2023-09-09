
// Dependencies
const fs = require('ssh2-fs');
const exec = require('ssh2-exec/promise');
const utils = require('../../../../utils');
const definitions = require('./schema.json');

// ## Errors
const errors = {
  NIKITA_FS_CWS_TARGET_ENOENT: ({config}) =>
    utils.error('NIKITA_FS_CWS_TARGET_ENOENT', [
      'fail to write a file,',
      !config.target_tmp
        ? `location is ${JSON.stringify(config.target)}.`
        : `location is ${JSON.stringify(config.target_tmp)} (temporary file, target is ${JSON.stringify(config.target)}).`
    ], {
      errno: -2,
      path: config.target_tmp || config.target, // Native Node.js api doesn't provide path
      syscall: 'open'
    })
};

// Action
module.exports = {
  handler: async function({
      config,
      metadata,
      ssh,
      tools: {log}
    }) {
    const sudo = (cmd) =>
      (config.sudo) ? `sudo ${cmd}` : `${cmd}`;
    // Normalize config
    if (config.sudo || config.flags[0] === 'a') {
      if (config.target_tmp == null) {
        config.target_tmp = `${metadata.tmpdir}/${utils.string.hash(config.target)}`;
      }
    }
    try {
      // config.mode ?= 0o644 # Node.js default to 0o666
      // In append mode, we write to a copy of the target file located in a temporary location
      if (config.flags[0] === 'a') {
        const whoami = utils.os.whoami(ssh);
        await exec(ssh, [
          sudo(`[ ! -f '${config.target}' ] && exit`),
          sudo(`cp '${config.target}' '${config.target_tmp}'`),
          sudo(`chown ${whoami} '${config.target_tmp}'`)].join('\n')
        );
        log({
          message: "Append prepared by placing a copy of the original file in a temporary path",
          level: 'INFO'
        });
      }
    } catch (error) {
      log({
        message: "Failed to place original file in temporary path",
        level: 'ERROR'
      });
      throw error;
    }
    // Start writing the content
    log({
      message: 'Start writing bytes',
      level: 'DEBUG'
    });
    await new Promise(async function(resolve, reject) {
      const ws = (await fs.createWriteStream(ssh, config.target_tmp || config.target, {
        flags: config.flags,
        mode: config.mode
      }));
      config.stream(ws);
      const error = false; // Quick fix ws sending both the error and close events on error
      ws.on('error', function(error) {
        if (error.code === 'ENOENT') {
          error = errors.NIKITA_FS_CWS_TARGET_ENOENT({
            config: config
          });
        }
        reject(error);
      });
      ws.on('end', () => ws.destroy() );
      ws.on('close', () => error || resolve() );
    });
    // Replace the target file in append or sudo mode
    if (config.target_tmp) {
      await exec(ssh, {
        command: [
          sudo(`mv '${config.target_tmp}' '${config.target}'`),
          config.sudo ? sudo(`chown root:root '${config.target}'`) : undefined
        ].join('\n')
      });
    }
  },
  metadata: {
    argument_to_config: 'target',
    log: false,
    raw_output: true,
    definitions: definitions
  },
  hooks: {
    on_action: {
      after: [
        '@nikitajs/core/lib/plugins/execute'
      ],
      before: [
        '@nikitajs/core/lib/plugins/metadata/schema',
        '@nikitajs/core/lib/plugins/metadata/tmpdir'
      ],
      handler: async function({
        config,
        metadata,
        tools: {find}
      }) {
        if (config.sudo == null) {
          config.sudo = await find( ({metadata: {sudo}}) => sudo );
        }
        if (config.sudo || config.flags?.[0] === 'a') {
          metadata.tmpdir = {
            sudo: false
          };
        }
      }
    }
  }
};
