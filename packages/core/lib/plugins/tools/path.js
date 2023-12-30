/*
Plugin `@nikitajs/core/plugins/tools/path`
*/

// Dependencies
import os from "node:os";
import path from "node:path";

// Plugin
export default {
  name: "@nikitajs/core/plugins/tools/path",
  hooks: {
    "nikita:action": {
      after: "@nikitajs/core/plugins/ssh",
      handler: function (action) {
        action.tools ??= {};
        // Path is alwaws posix over ssh
        // otherwise it is platform dependent
        action.tools.path = !action.ssh
          ? os.platform === "win32"
            ? path.win32
            : path.posix
          : path.posix;
        // Local is agnostic of ssh
        action.tools.path.local =
          os.platform === "win32" ? path.win32 : path.posix;
        // Reinject posix and win32 path for conveniency
        action.tools.path.posix = path.posix;
        action.tools.path.win32 = path.win32;
      },
    },
  },
};
