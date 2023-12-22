// Dependencies
import { Minimatch } from "minimatch";
import utils from '@nikitajs/core/utils';
import definitions from "./schema.json" assert { type: "json" };

// Utility
const getprefix = function(pattern) {
  let prefix = null;
  let n = 0;
  while (typeof pattern[n] === "string") {
    n++;
  }
  // now n is the index of the first one that is *not* a string.
  // see if there's anything else
  switch (n) {
    // if not, then this is rather simple
    case pattern.length:
      prefix = pattern.join('/');
      return prefix;
    case 0:
      // pattern *starts* with some non-trivial item.
      // going to readdir(cwd), but not include the prefix in matches.
      return null;
    default:
      // pattern has some string bits in the front.
      // whatever it starts with, whether that's "absolute" like /foo/bar,
      // or "relative" like "../baz"
      prefix = pattern.slice(0, n);
      prefix = prefix.join('/');
      return prefix;
  }
};

// Action
export default {
  handler: async function ({ config, tools: { path } }) {
    if (config.minimatch == null) {
      config.minimatch = {};
    }
    // config.minimatch.dot ?= config.dot if config.dot?
    // if (config.dot != null && config.minimatch.dot == null) {
    if (config.minimatch.dot == null) {
      config.minimatch.dot = config.dot;
    }
    config.target = path.normalize(config.target);
    const minimatch = new Minimatch(config.target, config.minimatch);
    let { stdout } = await this.execute({
      command: [
        'find',
        ...minimatch.set.map( getprefix ),
        // trailing slash
        '-type d -exec sh -c \'printf "%s/\\n" "$0"\' {} \\; -or -print',
      ].join(' '),
      $relax: true,
      trim: true,
    });
    // Find returns exit code 1 when no match is found, treat it as an empty output
    if (stdout == null) {
      stdout = "";
    }
    // Filter each entries
    let files = utils.string.lines(stdout).filter(function (file) {
      return minimatch.match(file);
    });
    // Remove the trailing slash introduced by the find command
    if (!config.trailing) {
      files = files.map( (file) =>
        file.slice(-1) === "/" ? file.slice(0, -1):file
      );
    }
    return {
      files: files,
    };
  },
  metadata: {
    argument_to_config: "target",
    definitions: definitions,
    shy: true,
  },
};
