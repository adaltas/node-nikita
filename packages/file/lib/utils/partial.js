/*

# Partial

Replace partial elements in a text.

*/

// Dependencies
const utils = require('@nikitajs/core/lib/utils');

// Utils
module.exports = function(config, log) {
  if(!config.write?.length > 0) return;
  log({
    message: "Replacing sections of the file",
    level: 'DEBUG'
  });
  // let orgContent;
  for (const opts of config.write) {
    if (opts.match) {
      if (opts.match == null) {
        opts.match = opts.replace;
      }
      if (typeof opts.match === 'string') {
        log({
          message: "Convert match string to regexp",
          level: 'DEBUG'
        });
      }
      if (typeof opts.match === 'string') {
        opts.match = RegExp(`${utils.regexp.quote(opts.match)}`, "mg");
      }
      if (!(opts.match instanceof RegExp)) {
        throw Error(`Invalid match option, got ${JSON.stringify(opts.match)} instead of a RegExp`);
      }
      if (opts.match.test(config.content)) {
        config.content = config.content.replace(opts.match, opts.replace);
        log({
          message: "Match existing partial",
          level: 'INFO'
        });
      } else if (opts.place_before && typeof opts.replace === 'string') {
        if (typeof opts.place_before === "string") {
          opts.place_before = new RegExp(RegExp(`^.*${utils.regexp.quote(opts.place_before)}.*$`, "mg"));
        }
        if (opts.place_before instanceof RegExp) {
          log({
            message: "Replace with match and place_before regexp",
            level: 'DEBUG'
          });
          let posoffset = 0;
          const orgContent = config.content;
          while ((res = opts.place_before.exec(orgContent)) !== null) {
            log({
              message: "Before regexp found a match",
              level: 'INFO'
            });
            const pos = posoffset + res.index; //+ res[0].length
            config.content = config.content.slice(0, pos) + opts.replace + '\n' + config.content.slice(pos);
            posoffset += opts.replace.length + 1;
            if (!opts.place_before.global) {
              break;
            }
          }
          // place_before = false; // if content
        } else {
          log({
            message: "Forgot how we could get there, test shall say it all",
            level: 'DEBUG'
          });
          const linebreak = config.content.length === 0 || config.content.substr(config.content.length - 1) === '\n' ? '' : '\n';
          config.content = opts.replace + linebreak + config.content;
        }
      } else if (opts.append && typeof opts.replace === 'string') {
        if (typeof opts.append === "string") {
          log({
            message: "Convert append string to regexp",
            level: 'DEBUG'
          });
          opts.append = new RegExp(`^.*${utils.regexp.quote(opts.append)}.*$`, 'mg');
        }
        if (opts.append instanceof RegExp) {
          log({
            message: "Replace with match and append regexp",
            level: 'DEBUG'
          });
          let posoffset = 0;
          const orgContent = config.content;
          while ((res = opts.append.exec(orgContent)) !== null) {
            log({
              message: "Append regexp found a match",
              level: 'INFO'
            });
            const pos = posoffset + res.index + res[0].length;
            config.content = config.content.slice(0, pos) + '\n' + opts.replace + config.content.slice(pos);
            posoffset += opts.replace.length + 1;
            if (!opts.append.global) {
              break;
            }
          }
        } else {
          const linebreak = config.content.length === 0 || config.content.substr(config.content.length - 1) === '\n' ? '' : '\n';
          config.content = config.content + linebreak + opts.replace;
        }
      } else {
        continue; // Did not match, try callback
      }
    } else if (opts.place_before === true) {
      log({
        message: "Before is true, need to explain how we could get here",
        level: 'INFO'
      });
    } else if (opts.from || opts.to) {
      if (opts.from && opts.to) {
        const from = RegExp(`(^${utils.regexp.quote(opts.from)}$)`, "m").exec(config.content);
        const to = RegExp(`(^${utils.regexp.quote(opts.to)}$)`, "m").exec(config.content);
        if ((from != null) && (to == null)) {
          log({
            message: "Found 'from' but missing 'to', skip writing",
            level: 'WARN'
          });
        } else if ((from == null) && (to != null)) {
          log({
            message: "Missing 'from' but found 'to', skip writing",
            level: 'WARN'
          });
        } else if ((from == null) && (to == null)) {
          if (opts.append) {
            config.content += '\n' + opts.from + '\n' + opts.replace + '\n' + opts.to;
          } else {
            log({
              message: "Missing 'from' and 'to' without append, skip writing",
              level: 'WARN'
            });
          }
        } else {
          config.content = config.content.substr(0, from.index + from[1].length + 1) + opts.replace + '\n' + config.content.substr(to.index);
        }
      } else if (opts.from && !opts.to) {
        const from = RegExp(`(^${utils.regexp.quote(opts.from)}$)`, "m").exec(config.content);
        if (from != null) {
          config.content = config.content.substr(0, from.index + from[1].length) + '\n' + opts.replace; // TODO: honors append
        } else {
          log({
            message: "Missing 'from', skip writing",
            level: 'WARN'
          });
        }
      } else if (!opts.from && opts.to) {
        const to = RegExp(`(^${utils.regexp.quote(opts.to)}$)`, "m").exec(config.content);
        if (to != null) {
          config.content = opts.replace + '\n' + config.content.substr(to.index); // TODO: honors append
        } else {
          log({
            message: "Missing 'to', skip writing",
            level: 'WARN'
          });
        }
      }
    }
  }
};
