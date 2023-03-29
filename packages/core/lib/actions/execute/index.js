
// Dependencies
const exec = require('ssh2-exec');
const execProm = require('ssh2-exec/promise');
const fs = require('ssh2-fs');
const yaml = require('js-yaml');
const utils = require('../../utils');
const definitions = require('./schema.json');

// Errors
const errors = {
  NIKITA_EXECUTE_ARCH_CHROOT_ROOTDIR_NOT_EXIST: function({err, config}) {
    return utils.error('NIKITA_EXECUTE_ARCH_CHROOT_ROOTDIR_NOT_EXIST', ['directory defined by `config.arch_chroot_rootdir` must exist,', `location is ${JSON.stringify(config.arch_chroot_rootdir)}.`], {
      exit_code: err.code,
      stdout: err.stdout,
      stderr: err.stderr
    });
  }
};

// Action
module.exports = {
  handler: async function({
    config,
    metadata,
    parent,
    tools: {dig, find, log, path, walk},
    ssh
  }) {
    // Validate parameters
    if (config.mode == null) {
      config.mode = 0o500;
    }
    if (typeof config.command === 'function') {
      config.command = (await this.call(config, config.command));
    }
    if (config.bash === true) {
      config.bash = 'bash';
    }
    if (config.arch_chroot === true) {
      config.arch_chroot = 'arch-chroot';
    }
    if (config.command && config.trap) {
      config.command = `set -e\n${config.command}`;
    }
    config.command_original = `${config.command}`;
    // sudo = await find ({config: {sudo}}) -> sudo
    const dry = (await find(function({
        config: {dry}
      }) {
      return dry;
    }));
    if (['bash', 'arch_chroot'].filter(function(k) {
      return config[k];
    }).length > 1) {
      // TODO move next 2 lines this to schema or on_action ?
      throw Error("Incompatible properties: bash, arch_chroot");
    }
    // Environment variables are merged with parent
    // env = merge {}, ...await walk ({config: {env}}) -> env
    // Serialize env in a sourced file
    const env_export = config.env_export != null ? config.env_export : !!ssh;
    let env_export_content = undefined;
    if (env_export && Object.keys(config.env).length) {
      env_export_content = (
        (function() {
          const results = [];
          for (const k in config.env) {
            const v = config.env[k];
            results.push(`export ${k}=${utils.string.escapeshellarg(v)}\n`);
          }
          return results;
        })()
      ).join('\n');
      const env_export_hash = utils.string.hash(env_export_content);
    }
    // Guess current username
    const current_username = utils.os.whoami(ssh);
    // Sudo
    if (config.sudo) {
      if (current_username === 'root') {
        config.sudo = false;
      } else {
        if (!['bash', 'arch_chroot'].some(function(k) {
          return config[k];
        })) {
          config.bash = 'bash';
        }
      }
    }
    // User substitution
    // Determines if writing is required and eventually convert uid to username
    if (config.uid && current_username !== 'root' && !/\d/.test(`${config.uid}`)) {
      const {stdout} = await this.execute({
        [`awk -v val=${config.uid} -F `]: " '$3==val{print $1}' /etc/passwd`"
      }, function(err, {stdout}) {});
      config.uid = stdout.trim();
      if (!(config.bash || config.arch_chroot)) {
        config.bash = 'bash';
      }
    }
    if (env_export && Object.keys(config.env).length) {
      const env_export_hash = utils.string.hash(env_export_content);
      const env_export_target = path.join(metadata.tmpdir, env_export_hash);
      config.command = `source ${env_export_target}\n${config.command}`;
      log({
        message: `Writing env export to ${JSON.stringify(env_export_target)}`,
        level: 'INFO'
      });
      await this.fs.base.writeFile({
        $sudo: config.sudo,
        content: env_export_content,
        mode: 0o500,
        target: env_export_target,
        uid: config.uid
      });
    }
    if (config.arch_chroot) {
      // Note, with arch_chroot enabled, 
      // arch_chroot_rootdir `/mnt` gave birth to
      // tmpdir `/mnt/tmpdir/nikita-random-path`
      // and target is inside it
      const command = config.command;
      const target_in = path.join(config.arch_chroot_tmpdir, `execute-arch_chroot-${utils.string.hash(config.command)}`);
      const target = path.join(config.arch_chroot_rootdir, target_in);
      // target = "#{metadata.tmpdir}/#{utils.string.hash config.command}" if typeof config.target isnt 'string'
      log({
        message: `Writing arch-chroot script to ${JSON.stringify(target)}`,
        level: 'INFO'
      });
      config.command = `${config.arch_chroot} ${config.arch_chroot_rootdir} bash ${target_in}`;
      if (config.sudo) {
        config.command = `sudo ${config.command}`;
      }
      await this.fs.base.writeFile({
        $sudo: config.sudo,
        target: `${target}`,
        content: `${command}`,
        mode: config.mode
      });
    // Write script
    } else if (config.bash) {
      const command = config.command;
      const target = path.join(metadata.tmpdir, `execute-bash-${utils.string.hash(config.command)}`);
      log({
        message: `Writing bash script to ${JSON.stringify(target)}`,
        level: 'INFO'
      });
      let cmd = `${config.bash} ${target}`;
      if (config.uid) {
        cmd = `su - ${config.uid} -c '${cmd}'`;
      }
      if (config.sudo) {
        cmd = `sudo ${cmd}`;
      }
      if (!config.dirty) {
        cmd += "; code=`echo $?` ";
        if (!config.sudo) {
          cmd += `&& rm '${target}'`;
        } else {
          cmd += `&& sudo rm '${target}'`;
        }
        cmd += "&& exit $code";
      }
      config.command = cmd;
      // config.command = "#{config.bash} #{target}"
      // config.command = "su - #{config.uid} -c '#{config.command}'" if config.uid
      // # Note, rm cannot be remove with arch_chroot enabled
      // config.command += " && code=`echo $?`; rm '#{target}'; exit $code" unless config.dirty
      await this.fs.base.writeFile({
        $sudo: config.sudo,
        content: command,
        mode: config.mode,
        target: target,
        uid: config.uid
      });
    } else if (config.sudo) {
      config.command = `sudo ${config.command}`;
    }
    // Execute
    return new Promise(function(resolve, reject) {
      if (config.stdin_log) {
        log({
          message: config.command_original,
          type: 'stdin',
          level: 'INFO'
        });
      }
      const result = {
        $status: false,
        stdout: [],
        stderr: [],
        code: null,
        command: config.command_original
      };
      if (config.dry) {
        return resolve(result);
      }
      const child = exec(config, {
        ssh: ssh,
        env: config.env
      });
      if (config.stdin && child.stdin) {
        // Note, child[stdin|stdout|stderr] are undefined
        // when option stdio is set to 'inherit'
        config.stdin.pipe(child.stdin);
      }
      if (config.stdout && child.stdout) {
        child.stdout.pipe(config.stdout, {
          end: false
        });
      }
      if (config.stderr && child.stderr) {
        child.stderr.pipe(config.stderr, {
          end: false
        });
      }
      let stdout_stream_open = stderr_stream_open = false;
      if (child.stdout && (config.stdout_return || config.stdout_log)) {
        child.stdout.on('data', function(data) {
          if (config.stdout_log) {
            stdout_stream_open = true;
          }
          if (config.stdout_log) {
            log({
              message: data,
              type: 'stdout_stream'
            });
          }
          if (config.stdout_return) {
            if (Array.isArray(result.stdout)) { // A string once `exit` is called
              return result.stdout.push(data);
            } else {
              return console.warn(['NIKITA_EXECUTE_STDOUT_INVALID:', 'stdout coming after child exit,', `got ${JSON.stringify(data.toString())},`, 'this is embarassing and we never found how to catch this bug,', 'we would really enjoy some help to replicate or fix this one.'].join(' '));
            }
          }
        });
      }
      if (child.stderr && (config.stderr_return || config.stderr_log)) {
        child.stderr.on('data', function(data) {
          if (config.stderr_log) {
            stderr_stream_open = true;
          }
          if (config.stderr_log) {
            log({
              message: data,
              type: 'stderr_stream'
            });
          }
          if (config.stderr_return) {
            if (Array.isArray(result.stderr)) { // A string once `exit` is called
              return result.stderr.push(data);
            } else {
              return console.warn(['NIKITA_EXECUTE_STDERR_INVALID:', 'stderr coming after child exit,', `got ${JSON.stringify(data.toString())},`, 'this is embarassing and we never found how to catch this bug,', 'we would really enjoy some help to replicate or fix this one.'].join(' '));
            }
          }
        });
      }
      return child.on("exit", function(code) {
        log({
          message: `Command exit with status: ${code}`,
          level: 'DEBUG'
        });
        result.code = code;
        // Give it some time because the "exit" event is sometimes called
        // before the "stdout" "data" event when running `npm test`
        return setImmediate(function() {
          if (stdout_stream_open && config.stdout_log) {
            log({
              message: null,
              type: 'stdout_stream'
            });
          }
          if (stderr_stream_open && config.stderr_log) {
            log({
              message: null,
              type: 'stderr_stream'
            });
          }
          result.stdout = result.stdout.map(function(d) {
            return d.toString();
          }).join('');
          if (config.trim || config.stdout_trim) {
            result.stdout = result.stdout.trim();
          }
          result.stderr = result.stderr.map(function(d) {
            return d.toString();
          }).join('');
          if (config.trim || config.stderr_trim) {
            result.stderr = result.stderr.trim();
          }
          if (config.format && config.code.true.indexOf(code) !== -1) {
            result.data = (function() {
              switch (config.format) {
                case 'json':
                  return JSON.parse(result.stdout);
                case 'yaml':
                  return yaml.load(result.stdout);
              }
            })();
          }
          if (result.stdout && result.stdout !== '' && config.stdout_log) {
            log({
              message: result.stdout,
              type: 'stdout'
            });
          }
          if (result.stderr && result.stderr !== '' && config.stderr_log) {
            log({
              message: result.stderr,
              type: 'stderr'
            });
          }
          if (child.stdout && config.stdout) {
            child.stdout.unpipe(config.stdout);
          }
          if (child.stderr && config.stderr) {
            child.stderr.unpipe(config.stderr);
          }
          if (config.code.true.indexOf(code) === -1 && config.code.false.indexOf(code) === -1) {
            log({
              message: ['An unexpected exit code was encountered,', metadata.relax ? 'using relax mode,' : void 0, `command is ${JSON.stringify(utils.string.max(config.command_original, 50))},`, `got ${JSON.stringify(result.code)}`, `instead of ${JSON.stringify(config.code)}.`].filter(function(line) {
                return !!line;
              }).join(' '),
              level: metadata.relax ? 'INFO' : 'ERROR'
            });
            return reject(utils.error('NIKITA_EXECUTE_EXIT_CODE_INVALID', ['an unexpected exit code was encountered,', metadata.relax ? 'using relax mode,' : void 0, `command is ${JSON.stringify(utils.string.max(config.command_original, 50))},`, `got ${JSON.stringify(result.code)}`, `instead of ${JSON.stringify(config.code)}.`], {
              ...result,
              exit_code: code
            }));
          }
          if (config.code.false.indexOf(code) === -1) {
            result.$status = true;
          } else {
            log({
              message: `Skip exit code \`${code}\``,
              level: 'INFO'
            });
          }
          return resolve(result);
        });
      });
    });
  },
  hooks: {
    on_action: {
      after: ['@nikitajs/core/lib/plugins/execute', '@nikitajs/core/lib/plugins/ssh', '@nikitajs/core/lib/plugins/tools/path'],
      before: ['@nikitajs/core/lib/plugins/metadata/schema', '@nikitajs/core/lib/plugins/metadata/tmpdir'],
      handler: function({
        config,
        metadata,
        ssh,
        tools: {find, path, walk}
      }) {
        if (config.env == null) {
          config.env = !ssh && !config.env ? process.env : {};
        }
        const env_export = config.env_export != null ? config.env_export : !!ssh;
        // Create the tmpdir if arch_chroot is activated
        if (config.arch_chroot && config.arch_chroot_rootdir) {
          return metadata.tmpdir != null ? metadata.tmpdir : metadata.tmpdir = async function({os_tmpdir, tmpdir}) {
            // Note, Arch mount `/tmp` with tmpfs in memory
            // placing a file in the host fs will not expose it inside of chroot
            config.arch_chroot_tmpdir = path.join('/opt', tmpdir);
            tmpdir = path.join(config.arch_chroot_rootdir, config.arch_chroot_tmpdir);
            const sudo = function(command) {
              if (utils.os.whoami(ssh) === 'root') {
                return command;
              } else {
                return `sudo ${command}`;
              }
            };
            const command = ['set -e', sudo(`[ -w ${config.arch_chroot_rootdir} ] || exit 2;`), sudo(`mkdir -p ${tmpdir};`), sudo(`chmod 700 ${tmpdir};`)].join('\n');
            try {
              await execProm(ssh, command);
            } catch (error) {
              if (error.code === 2) {
                throw errors.NIKITA_EXECUTE_ARCH_CHROOT_ROOTDIR_NOT_EXIST({
                  err: error,
                  config: config
                });
              }
              throw error;
            }
            return {
              target: tmpdir
            };
          };
        } else if (config.sudo || config.bash || (env_export && Object.keys(config.env).length)) {
          return metadata.tmpdir != null ? metadata.tmpdir : metadata.tmpdir = true;
        }
      }
    },
    on_result: {
      before: '@nikitajs/core/lib/plugins/ssh',
      handler: async function({
          action: {config, metadata, ssh}
        }) {
        // Only arch chroot manage tmpdir, otherwise it is handled by the plugin
        if (!(config.arch_chroot && config.arch_chroot_rootdir)) {
          return;
        }
        // Disregard cleaning if tmpdir is a user defined function and if
        // the function failed to execute, see the on_action hook above.
        if (typeof metadata.tmpdir === 'function') {
          return;
        }
        const sudo = function(command) {
          if (utils.os.whoami(ssh) === 'root') {
            return command;
          } else {
            return `sudo ${command}`;
          }
        };
        const command = [sudo(`rm -rf ${metadata.tmpdir}`)].join('\n');
        return (await execProm(ssh, command));
      }
    }
  },
  metadata: {
    argument_to_config: 'command',
    definitions: definitions
  }
};
