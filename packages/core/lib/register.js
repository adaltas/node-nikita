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
      mkdir: "@nikitajs/core/actions/fs/base/mkdir",
    },
    assert: "@nikitajs/core/actions/fs/assert",
    chmod: "@nikitajs/core/actions/fs/chmod",
    chown: "@nikitajs/core/actions/fs/chown",
    copy: "@nikitajs/core/actions/fs/copy",
    createReadStream: "@nikitajs/core/actions/fs/createReadStream",
    createWriteStream: "@nikitajs/core/actions/fs/createWriteStream",
    exists: "@nikitajs/core/actions/fs/exists",
    glob: "@nikitajs/core/actions/fs/glob",
    hash: "@nikitajs/core/actions/fs/hash",
    link: "@nikitajs/core/actions/fs/link",
    lstat: "@nikitajs/core/actions/fs/lstat",
    mkdir: "@nikitajs/core/actions/fs/mkdir",
    move: "@nikitajs/core/actions/fs/move",
    readdir: "@nikitajs/core/actions/fs/readdir",
    readFile: "@nikitajs/core/actions/fs/readFile",
    readlink: "@nikitajs/core/actions/fs/readlink",
    remove: "@nikitajs/core/actions/fs/remove",
    rename: "@nikitajs/core/actions/fs/rename",
    unlink: "@nikitajs/core/actions/fs/unlink",
    rmdir: "@nikitajs/core/actions/fs/rmdir",
    stat: "@nikitajs/core/actions/fs/stat",
    symlink: "@nikitajs/core/actions/fs/symlink",
    wait: "@nikitajs/core/actions/fs/wait",
    writeFile: "@nikitajs/core/actions/fs/writeFile",
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
