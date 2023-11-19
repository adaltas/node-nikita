// Dependencies
import registry from "@nikitajs/core/registry";

// Action registration
const actions = {
  log: {
    cli: "@nikitajs/log/cli",
    csv: "@nikitajs/log/csv",
    fs: "@nikitajs/log/fs",
    md: "@nikitajs/log/md",
    stream: "@nikitajs/log/stream",
  },
};

await registry.register(actions);
