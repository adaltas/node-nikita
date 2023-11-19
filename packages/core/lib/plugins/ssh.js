/*
# Plugin @nikitajs/core/plugins/ssh

Pass an SSH connection to an action. The connection is accessible with the
`action.ssh` property.
*/

// Denpendencies
import utils from "@nikitajs/core/utils";
import {with_options as session} from "@nikitajs/core/session";
// Nikita plugins
import events from "@nikitajs/core/plugins/tools/events";
import find from "@nikitajs/core/plugins/tools/find";
import log from "@nikitajs/core/plugins/tools/log";
import status from "@nikitajs/core/plugins/output/status";
import raw from "@nikitajs/core/plugins/metadata/raw";
import history from "@nikitajs/core/plugins/history";

// Plugin
export default {
  name: "@nikitajs/core/plugins/ssh",
  require: ["@nikitajs/core/plugins/tools/find"],
  hooks: {
    "nikita:action": async function (action) {
      // Is there a connection to open
      if (action.ssh && !utils.ssh.is(action.ssh)) {
        let { ssh } = await session([{}], {
            plugins: [events, find, log, status, raw, history], // Need to inject `tools.log`
          })
          .ssh.open(action.ssh);
        action.metadata.ssh_dispose = true;
        action.ssh = ssh;
        return;
      }
      // Find SSH connection in parent actions
      let ssh = await action.tools.find((action) => action.ssh);
      if (ssh) {
        if (!utils.ssh.is(ssh)) {
          throw utils.error("NIKITA_SSH_INVALID_STATE", [
            "the `ssh` property is not a connection",
            `got ${JSON.stringify(ssh)}`,
          ]);
        }
        action.ssh = ssh;
        return;
      } else if (ssh === null || ssh === false) {
        if (action.ssh !== undefined) {
          action.ssh = null;
        }
        return;
      } else if (ssh !== void 0) {
        throw utils.error("NIKITA_SSH_INVALID_VALUE", [
          "when disabled, the `ssh` property must be `null` or `false`,",
          "when enable, the `ssh` property must be a connection or a configuration object",
          `got ${JSON.stringify(ssh)}`,
        ]);
      }
      // Find SSH open in previous siblings
      for (let i = 0; i < action.siblings.length; i++) {
        const sibling = action.siblings[i];
        if (sibling.metadata.module !== "@nikitajs/core/actions/ssh/open") {
          continue;
        }
        if (sibling.output.ssh) {
          ssh = sibling.output.ssh;
          break;
        }
      }
      // Then only set the connection if still open
      if (ssh && (ssh._sshstream?.writable || ssh._sock?.writable)) {
        action.ssh = ssh;
      }
    },
    "nikita:result": async function ({ action }) {
      if (action.metadata.ssh_dispose) {
        return await session([{}], {
          plugins: [events, history, find, log, raw, status], // Need to inject `tools.log`
        }).ssh.close({
          ssh: action.ssh,
        });
      }
    },
  },
};
