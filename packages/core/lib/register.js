// Dependencies
import registry from "@nikitajs/core/registry";

// Action registration
const actions = {
  "": {},
  assert: "@nikitajs/core/actions/assert",
  call: "@nikitajs/core/actions/call",
  execute: {
    "": "@nikitajs/core/actions/execute",
    assert: "@nikitajs/core/actions/execute/assert",
    wait: "@nikitajs/core/actions/execute/wait",
  },
  fs: {
    base: {
      chmod: "@nikitajs/core/actions/fs/base/chmod",
      chown: "@nikitajs/core/actions/fs/base/chown",
      copy: "@nikitajs/core/actions/fs/base/copy",
      createReadStream: "@nikitajs/core/actions/fs/base/createReadStream",
      createWriteStream: "@nikitajs/core/actions/fs/base/createWriteStream",
      exists: "@nikitajs/core/actions/fs/base/exists",
      lstat: "@nikitajs/core/actions/fs/base/lstat",
      mkdir: "@nikitajs/core/actions/fs/base/mkdir",
      readdir: "@nikitajs/core/actions/fs/base/readdir",
      readFile: "@nikitajs/core/actions/fs/base/readFile",
      readlink: "@nikitajs/core/actions/fs/base/readlink",
      rename: "@nikitajs/core/actions/fs/base/rename",
      rmdir: "@nikitajs/core/actions/fs/base/rmdir",
      stat: "@nikitajs/core/actions/fs/base/stat",
      symlink: "@nikitajs/core/actions/fs/base/symlink",
      unlink: "@nikitajs/core/actions/fs/base/unlink",
      writeFile: "@nikitajs/core/actions/fs/base/writeFile",
    },
    assert: "@nikitajs/core/actions/fs/assert",
    chmod: "@nikitajs/core/actions/fs/chmod",
    chown: "@nikitajs/core/actions/fs/chown",
    copy: "@nikitajs/core/actions/fs/copy",
    glob: "@nikitajs/core/actions/fs/glob",
    hash: "@nikitajs/core/actions/fs/hash",
    link: "@nikitajs/core/actions/fs/link",
    mkdir: "@nikitajs/core/actions/fs/mkdir",
    move: "@nikitajs/core/actions/fs/move",
    remove: "@nikitajs/core/actions/fs/remove",
    wait: "@nikitajs/core/actions/fs/wait",
  },
  registry: {
    get: "@nikitajs/core/actions/registry/get",
    register: "@nikitajs/core/actions/registry/register",
    registered: "@nikitajs/core/actions/registry/registered",
    unregister: "@nikitajs/core/actions/registry/unregister",
  },
  ssh: {
    open: "@nikitajs/core/actions/ssh/open",
    close: "@nikitajs/core/actions/ssh/close",
    root: "@nikitajs/core/actions/ssh/root",
  },
  wait: "@nikitajs/core/actions/wait",
};

await registry.register(actions);
