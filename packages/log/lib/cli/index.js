// Dependencies
import colors from 'colors/safe.js';
import {merge} from 'mixme';
import pad from 'pad';
import utils from '@nikitajs/core/utils';
import definitions from "./schema.json" assert { type: "json" };

// Utils
const format_line = function ({ host, header, status, time }, config) {
  if (config.pad.host) {
    host = pad(host, config.pad.host);
  }
  if (config.pad.header) {
    header = pad(header, config.pad.header);
  }
  if (config.pad.time) {
    time = pad(time, config.pad.time);
  }
  return [
    host,
    config.separator.host,
    header,
    config.separator.header,
    status,
    config.time ? config.separator.time : "",
    time,
  ].join("");
};

// Action
export default {
  ssh: false,
  handler: function ({ config }) {
    // Normalize
    if (config.stream == null) {
      config.stream = process.stderr;
    }
    if (typeof config.separator === "string") {
      config.separator = {
        host: config.separator,
        header: config.separator,
      };
    }
    if (config.separator.host == null) {
      config.separator.host = config.pad.host == null ? "   " : " ";
    }
    if (config.separator?.header == null) {
      config.separator.header = config.pad.header == null ? "   " : " ";
    }
    if (config.separator?.time == null) {
      config.separator.time = config.pad.time == null ? "  " : " ";
    }
    if (config.colors == null) {
      config.colors = process.stdout.isTTY;
    }
    if (config.colors === true) {
      config.colors = {
        status_true: colors.green,
        status_false: colors.cyan.dim,
        status_error: colors.red,
      };
    }
    // Events
    const serializer = {
      "nikita:action:start": function ({ action }) {
        if (!config.enabled) {
          return;
        }
        const headers = get_headers(action);
        if (config.depth_max && config.depth_max < headers.length) {
          return;
        }
        return null;
      },
      "nikita:resolved": function ({ action }) {
        const color = config.colors ? config.colors.status_true : false;
        let line = format_line({
          host: config.host ?? action.ssh?.config?.host ?? "local",
          header: "",
          status: "♥",
          time: "",
        }, config);
        if (color) {
          line = color(line);
        }
        return line + "\n";
      },
      "nikita:rejected": function ({ action, error }) {
        const color = config.colors ? config.colors.status_error : false;
        let line = format_line({
          host: config.host ?? action.ssh?.config?.host ?? "local",
          header: "",
          status: "✘",
          time: "",
        }, config);
        if (color) {
          line = color(line);
        }
        return line + "\n";
      },
      "nikita:action:end": function ({ action, error, output }) {
        if (!action.metadata.header) {
          return;
        }
        if (config.depth_max && config.depth_max < action.metadata.depth) {
          return;
        }
        // TODO: I don't like this, the `end` event should receive raw output
        // with error not placed inside output by the history plugin
        error = error || (action.metadata.relax && output.error);
        const status = error
          ? "✘"
          : (output != null ? output.$status : void 0) && !action.metadata.shy
          ? "✔"
          : "-";
        const color = !config.colors ? false :  error
            ? config.colors.status_error
            : (output != null ? output.$status : void 0)
            ? config.colors.status_true
            : config.colors.status_false;
        if (action.metadata.disabled) {
          return null;
        }
        const headers = get_headers(action); 
        let line = format_line({
          host: config.host ?? action.ssh?.config?.host ?? "local",
          header: headers.join(config.divider),
          status: status,
          time: config.time
            ? utils.string.print_time(
                action.metadata.time_end - action.metadata.time_start
              )
            : "",
        }, config);
        if (color) {
          line = color(line);
        }
        return line + "\n";
      },
    };
    config.serializer = merge(serializer, config.serializer);
    return this.log.stream(config);
  },
  metadata: {
    argument_to_config: "enabled",
    definitions: definitions,
  },
};

const get_headers = function(action) {
  const walk = function(parent) {
    const precious = parent.metadata.header;
    const results = [];
    if (precious !== void 0) {
      results.push(precious);
    }
    if (parent.parent) {
      results.push(...(walk(parent.parent)));
    }
    return results;
  };
  const headers = walk(action);
  return headers.reverse();
};
