import array from "@nikitajs/utils/array";
import string from "@nikitajs/utils/string";
import jsesc from "jsesc";
import { merge } from "mixme";

const _equals = function (obj1, obj2, keys) {
  let keys1 = Object.keys(obj1);
  let keys2 = Object.keys(obj2);
  if (keys) {
    keys1 = keys1.filter(function (k) {
      return keys.indexOf(k) !== -1;
    });
    keys2 = keys2.filter(function (k) {
      return keys.indexOf(k) !== -1;
    });
  } else {
    keys = keys1;
  }
  if (keys1.length !== keys2.length) {
    return false;
  }
  for (const i in keys) {
    const key = keys[i];
    if (obj1[key] !== obj2[key]) {
      return false;
    }
  }
  return true;
};

const constants = {
  add_properties: [
    "--protocol",
    "--source",
    "---target",
    "--jump",
    "--goto",
    "--in-interface",
    "--out-interface",
    "--fragment",
    "tcp|--source-port",
    "tcp|--sport",
    "tcp|--target-port",
    "tcp|--dport",
    "tcp|--tcp-flags",
    "tcp|--syn",
    "tcp|--tcp-option",
    "udp|--source-port",
    "udp|--sport",
    "udp|--target-port",
    "udp|--dport",
  ],
  modify_properties: [
    "--set-counters",
    "--log-level",
    "--log-prefix",
    "--log-tcp-sequence",
    "--log-tcp-options", // LOG
    "--log-ip-options",
    "--log-uid", // LOG
    "state|--state",
    "comment|--comment",
    "limit|--limit",
  ],
  // Used to compute rulenum
  commands_arguments: {
    "-A": ["chain"],
    "-D": ["chain"],
    "-I": ["chain"],
    "-R": ["chain"],
    "-N": ["chain"],
    "-X": ["chain"],
    "-P": ["chain", "target"],
    "-L": true,
    "-S": true,
    "-F": true,
    "-Z": true,
    "-E": true,
  },
  commands_inverted: {
    "--append": "-A",
    "--delete": "-D",
    "--insert": "-I",
    "--replace": "-R",
    "--new-chain": "-N",
    "--delete-chain": "-X",
    "--policy": "-P",
    "--list": "-L",
    "--list-rules": "-S",
    "--flush": "-F",
    "--zero": "-Z",
    "--rename-chain": "-E",
  },
  parameters: [
    "--protocol",
    "--source",
    "--target",
    "--jump",
    "--goto",
    "--in-interface",
    "--out-interface",
    "--fragment",
    "--set-counters",
    "--log-level",
    "--log-prefix",
    "--log-tcp-sequence",
    "--log-tcp-options", // LOG
    "--log-ip-options",
    "--log-uid", // LOG
  ],
  parameters_inverted: {
    "-p": "--protocol",
    "-s": "--source",
    "-d": "--target",
    "-j": "--jump",
    "-g": "--goto",
    "-i": "--in-interface",
    "-o": "--out-interface",
    "-f": "--fragment",
    "-c": "--set-counters",
  },
  protocols: {
    tcp: [
      "--source-port",
      "--sport",
      "--target-port",
      "--dport",
      "--tcp-flags",
      "--syn",
      "--tcp-option",
    ],
    udp: ["--source-port", "--sport", "--target-port", "--dport"],
    udplite: [],
    icmp: [],
    esp: [],
    ah: [],
    sctp: [],
    all: [],
  },
  modules: {
    state: ["--state"],
    comment: ["--comment"],
    limit: ["--limit"],
  },
};

const command_args = function (command, rule) {
  for (const k in rule) {
    const v = rule[k];
    if (["chain", "rulenum", "command"].indexOf(k) !== -1) {
      continue;
    }
    if (v == null) {
      continue;
    }
    const match = /^([\w]+)\|([-\w]+)$/.exec(k);
    if (match) {
      const module = match[1];
      const arg = match[2];
      command += ` -m ${module}`;
      command += ` ${arg} ${v}`;
    } else {
      command += ` ${k} ${v}`;
    }
  }
  return command;
};

const command_replace = function (rule) {
  if (rule.rulenum == null) {
    rule.rulenum = 1;
  }
  return command_args(`iptables -R ${rule.chain} ${rule.rulenum}`, rule);
};

const command_insert = function (rule) {
  if (rule.rulenum == null) {
    rule.rulenum = 1;
  }
  return command_args(`iptables -I ${rule.chain} ${rule.rulenum}`, rule);
};

const command_append = function (rule) {
  if (rule.rulenum == null) {
    rule.rulenum = 1;
  }
  return command_args(`iptables -A ${rule.chain}`, rule);
};

const command = function (oldrules, newrules) {
  const commands = [];
  const new_chains = [];
  const old_chains = oldrules
    .map(function (oldrule) {
      return oldrule.chain;
    })
    .filter(function (chain, i, chains) {
      return (
        ["INPUT", "FORWARD", "OUTPUT"].indexOf(chain) < 0 &&
        chains.indexOf(chain) >= i
      );
    });
  // Create new chains
  for (const newrule of newrules) {
    if (
      ["INPUT", "FORWARD", "OUTPUT"].indexOf(newrule.chain) < 0 &&
      new_chains.indexOf(newrule.chain) < 0 &&
      old_chains.indexOf(newrule.chain) < 0
    ) {
      new_chains.push(newrule.chain);
      commands.push(`iptables -N ${newrule.chain}`);
    }
  }
  for (const newrule of newrules) {
    // break if newrule.rulenum? #or newrule.command is '-A'
    if (newrule.after && !newrule.rulenum) {
      for (const oldrule of oldrules) {
        if (!(oldrule.command === "-A" && oldrule.chain === newrule.chain)) {
          continue;
        }
        if (_equals(newrule.after, oldrule, Object.keys(newrule.after))) {
          // newrule.rulenum = rulenum + 1
          newrule.rulenum = oldrule.rulenum + 1;
        }
      }
      // break
      delete newrule.after;
    }
    if (newrule.before && !newrule.rulenum) {
      for (const oldrule of oldrules) {
        if (!(oldrule.command === "-A" && oldrule.chain === newrule.chain)) {
          continue;
        }
        if (_equals(newrule.before, oldrule, Object.keys(newrule.before))) {
          // newrule.rulenum = rulenum
          newrule.rulenum = oldrule.rulenum;
          break;
        }
      }
      delete newrule.before;
    }
    let create = true;
    // Get add properties present in new rule
    const add_properties = array.intersect(
      constants.add_properties,
      Object.keys(newrule),
    );
    for (const oldrule of oldrules) {
      if (oldrule.chain !== newrule.chain) {
        continue;
      }
      // Add properties are the same
      if (_equals(newrule, oldrule, add_properties)) {
        create = false;
        // Check if we need to update
        if (!_equals(newrule, oldrule, constants.modify_properties)) {
          // Remove the command
          const baserule = merge(oldrule);
          for (const k in baserule) {
            if (constants.commands_arguments[k]) {
              baserule[k] = undefined;
            }
            baserule.command = undefined;
            newrule.rulenum = undefined;
          }
          commands.push(command_replace(merge(baserule, newrule)));
        }
      }
    }
    // Add properties are different
    if (create) {
      commands.push(
        newrule.command === "-A" ?
          command_append(newrule)
        : command_insert(newrule),
      );
    }
  }
  return commands;
};

const normalize = function (rules, position = true) {
  const oldrules = merge(Array.isArray(rules) ? rules : [rules]);
  const newrules = [];
  for (const oldrule of oldrules) {
    let newrule = {};
    // Search for commands and parameters
    for (const key in oldrule) {
      let value = oldrule[key];
      let nkey = null;
      if (typeof value === "number") {
        // Normalize value as string
        value = oldrule[key] = `${value}`;
      }
      // Normalize key as shortname (eg "-k")
      if (key === "chain" || key === "rulenum" || key === "command") {
        // Final name, mark key as done
        nkey = key;
      } else if (
        key.slice(0, 2) === "--" &&
        constants.parameters.indexOf(key) >= 0
      ) {
        // nkey = constants.parameters_inverted[k]
        nkey = key;
      } else if (
        key[0] !== "-" &&
        constants.parameters.indexOf(`--${key}`) >= 0
      ) {
        // nkey = constants.parameters_inverted["--#{key}"]
        nkey = `--${key}`;
        // else if constants.parameters.indexOf(key) isnt -1
      } else if (constants.parameters_inverted[key]) {
        nkey = constants.parameters_inverted[key];
      }
      // nkey = key
      // Key has changed, replace it
      if (nkey) {
        newrule[nkey] = value;
        oldrule[key] = null;
      }
    }
    // Add prototol specific options
    const protocol = newrule["--protocol"];
    if (protocol != null) {
      for (const key of constants.protocols[protocol]) {
        if (oldrule[key]) {
          newrule[`${protocol}|${key}`] = oldrule[key];
          oldrule[key] = null;
        } else if (oldrule[key.slice(2)]) {
          newrule[`${protocol}|${key}`] = oldrule[key.slice(2)];
          oldrule[key.slice(2)] = null;
        }
      }
    }
    for (let key in oldrule) {
      const value = oldrule[key];
      if (!value) {
        continue;
      }
      if (key === "after" || key === "before") {
        newrule[key] = normalize(value, false);
        continue;
      }
      if (key.slice(0, 2) !== "--") {
        key = `--${key}`;
      }
      for (const mk in constants.modules) {
        const mvs = constants.modules[mk];
        for (const mv of mvs) {
          if (key === mv) {
            newrule[`${mk}|${key}`] = value;
            oldrule[key] = null;
          }
        }
      }
    }
    for (const key in newrule) {
      let value = newrule[key];
      if (key === "command") {
        continue;
      }
      // Discard default log level value
      if (key === "--log-level" && value === "4") {
        delete newrule[key];
        continue;
      }
      if (key === "comment|--comment") {
        // IPTables silently remove minus signs
        value = value.replace("-", "");
      }
      if (["--log-prefix", "comment|--comment"].indexOf(key) !== -1) {
        value = jsesc(value, {
          quotes: "double",
          wrap: true,
        });
      }
      newrule[key] = value;
    }
    newrules.push(newrule);
    if (position && newrule.command !== "-A") {
      for (const newrule of newrules) {
        if (!(newrule.after != null || newrule.before != null)) {
          newrule.after = {
            "-A": "INPUT",
            chain: "INPUT",
            "--jump": "ACCEPT",
          };
        }
      }
    }
  }
  if (Array.isArray(rules)) {
    return newrules;
  } else {
    return newrules[0];
  }
};

/*
Parse the result of `iptables -S`
*/
const parse = function (stdout) {
  const rules = [];
  const command_index = {};
  for (const line of string.lines(stdout)) {
    if (line.length === 0) {
      continue;
    }
    const rule = {};
    let i = 0;
    let key = "";
    let value = "";
    let module = null;
    while (i <= line.length) {
      let char = line[i];
      const forceflush = i === line.length;
      const newarg =
        (i === 0 && char === "-") || line.slice(i - 1, +i + 1 || 9e9) === " -";
      if (newarg || forceflush) {
        if (value) {
          value = value.trim();
          if (key === "-m") {
            module = value;
          } else {
            if (module) {
              key = `${module}|${key}`;
            }
            if (constants.parameters_inverted[key]) {
              key = constants.parameters_inverted[key];
            }
            rule[key] = value;
          }
          // First key is a command
          if (constants.commands_arguments[key]) {
            // Determine rule number
            if (Array.isArray(constants.commands_arguments[key])) {
              rule.command = key;
              const valueSplit = value.split(" ");
              for (const k in valueSplit) {
                rule[constants.commands_arguments[key][k]] = valueSplit[k];
              }
              if (command_index[rule.chain] == null) {
                command_index[rule.chain] = 0;
              }
              if (["-P", "-N"].indexOf(key) === -1) {
                rule.rulenum = ++command_index[rule.chain];
              }
            }
          }
          key = "";
          value = "";
          if (forceflush) {
            break;
          }
        }
        key += char;
        while ((char = line[++i]) !== " ") {
          // and line[i]?
          key += char;
        }
        // if constants.parameters.indexOf(key) isnt -1
        if (constants.parameters_inverted[key]) {
          module = null;
        }
        continue;
      }
      if (char === '"') {
        while ((char = line[++i]) !== '"') {
          value += char;
        }
        i++;
        continue;
      }
      while (char + (char = line[++i]) !== " -" && i < line.length) {
        if (char === "-" && key === "--comment") {
          // IPTable silently remove minus sign from comment
          continue;
        }
        value += char;
      }
    }
    rules.push(rule);
  }
  return rules;
};

export {
  constants,
  command_args,
  command_replace,
  command_insert,
  command_append,
  command,
  normalize,
  parse,
};

export default {
  constants,
  command_args: command_args,
  command_replace: command_replace,
  command_insert: command_insert,
  command_append: command_append,
  command: command,
  normalize: normalize,
  parse: parse,
};
