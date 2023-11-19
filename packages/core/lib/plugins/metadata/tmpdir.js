import { is_object_literal } from "mixme";
import utils from "@nikitajs/core/utils";
import os from "os";
import fs from "ssh2-fs";
import exec from "ssh2-exec/promises";

export default {
  name: "@nikitajs/core/plugins/metadata/tmpdir",
  require: [
    "@nikitajs/core/plugins/tools/find",
    "@nikitajs/core/plugins/tools/path",
  ],
  hooks: {
    // 'nikita:schema': ({schema}) ->
    //   mutate schema.definitions.metadata.properties,
    //     tmpdir:
    //       oneOf: [
    //         type: ['boolean', 'string']
    //       ,
    //         typeof: 'function'
    //       ]
    //       description: '''
    //       Creates a temporary directory for the duration of the action
    //       execution.
    //       '''
    "nikita:action": {
      before: ["@nikitajs/core/plugins/templated"],
      after: [
        "@nikitajs/core/plugins/execute",
        "@nikitajs/core/plugins/ssh",
        "@nikitajs/core/plugins/tools/path",
        "@nikitajs/core/plugins/metadata/uuid",
      ],
      // Probably related to pb above
      // '@nikitajs/core/plugins/metadata/schema'
      handler: async function (action) {
        const { config, metadata, tools } = action;
        if (
          !["boolean", "function", "string", "undefined"].includes(
            typeof metadata.tmpdir
          ) &&
          !is_object_literal(metadata.tmpdir)
        ) {
          throw utils.error("METADATA_TMPDIR_INVALID", [
            'the "tmpdir" metadata value must be a boolean, a function, an object or a string,',
            `got ${JSON.stringify(metadata.tmpdir)}`,
          ]);
        }
        // tmpdir is explicit, it must be defined to be available as a metadata
        // wether we switch with sudo or ssh, if not defined, there is nothing to do
        if (!metadata.tmpdir) {
          return;
        }
        // SSH connection extraction
        const ssh =
          config.ssh === false
            ? undefined
            : await tools.find((action) => action.ssh);
        // Sudo extraction
        const sudo = await tools.find(({ metadata }) => metadata.sudo);
        // Generate temporary location
        const os_tmpdir = ssh ? "/tmp" : os.tmpdir();
        const ssh_hash = ssh ? utils.ssh.hash(ssh) : null;
        const tmp_hash = utils.string.hash(
          JSON.stringify({
            ssh_hash: ssh_hash,
            sudo: sudo,
            uuid: metadata.uuid,
          })
        );
        const tmpdir_info = await (async function () {
          switch (typeof metadata.tmpdir) {
            case "string":
              return {
                target: metadata.tmpdir,
              };
            case "boolean":
              return {
                target: "nikita-" + tmp_hash,
                hash: tmp_hash,
              };
            case "function":
              return await metadata.tmpdir.call(null, {
                action: action,
                os_tmpdir: os_tmpdir,
                tmpdir: "nikita-" + tmp_hash,
              });
            case "object":
              // metadata.tmpdir.target ?= 'nikita-'+tmp_hash
              return metadata.tmpdir;
            default:
              return void 0;
          }
        })();
        // Current context
        if (tmpdir_info.uuid == null) {
          tmpdir_info.uuid = metadata.uuid;
        }
        if (tmpdir_info.ssh_hash == null) {
          tmpdir_info.ssh_hash = ssh_hash;
        }
        if (tmpdir_info.sudo == null) {
          tmpdir_info.sudo = sudo;
        }
        if (tmpdir_info.mode == null) {
          tmpdir_info.mode = 0o0744;
        }
        if (tmpdir_info.hash == null) {
          tmpdir_info.hash = utils.string.hash(JSON.stringify(tmpdir_info));
        }
        if (tmpdir_info.target == null) {
          tmpdir_info.target = "nikita-" + tmpdir_info.hash;
        }
        tmpdir_info.target = tools.path.resolve(os_tmpdir, tmpdir_info.target);
        metadata.tmpdir = tmpdir_info.target;
        const exists =
          action.parent &&
          (await tools.find(action.parent, function ({ metadata }) {
            if (!metadata.tmpdir) {
              return;
            }
            if (tmpdir_info.hash === metadata.tmpdir_info?.hash) {
              return true;
            }
          }));
        if (exists) {
          return;
        }
        try {
          await fs.mkdir(ssh, metadata.tmpdir, tmpdir_info.mode);
          if (tmpdir_info.sudo) {
            await exec(ssh, `sudo chown root:root '${metadata.tmpdir}'`);
          }
          metadata.tmpdir_info = tmpdir_info;
        } catch (error) {
          if (error.code !== "EEXIST") {
            throw error;
          }
        }
      },
    },
    "nikita:result": {
      before: "@nikitajs/core/plugins/ssh",
      handler: async function ({ action }) {
        const { config, metadata, tools } = action;
        // Value of tmpdir could still be true if there was an error in
        // one of the on_action hook, such as a invalid schema validation
        if (typeof metadata.tmpdir !== "string") {
          return;
        }
        if (!metadata.tmpdir_info) {
          return;
        }
        if (await tools.find(({ metadata }) => metadata.dirty)) {
          return;
        }
        // SSH connection extraction
        const ssh =
          config.ssh === false
            ? undefined
            : await tools.find(action, (action) => action.ssh);
        // Temporary directory decommissioning
        await exec(
          ssh,
          [
            metadata.tmpdir_info.sudo ? "sudo" : undefined,
            `rm -r '${metadata.tmpdir}'`,
          ].join(" ")
        );
      },
    },
  },
};
