// Dependencies
import ini from "ini";
import utils from "@nikitajs/core/utils";

// Remove undefined and null values
const safe = function (val) {
  if (
    typeof val !== "string" ||
    val.match(/[\r\n]/) ||
    val.match(/^\[/) ||
    (val.length > 1 && val.charAt(0) === '"' && val.slice(-1) === '"') ||
    val !== val.trim()
  ) {
    return JSON.stringify(val);
  } else {
    return val.replace(/;/g, "\\;");
  }
};

const split_by_dots = function (str) {
  return str
    .replace(/\\1/g, "\\2LITERAL\\1LITERAL\\2")
    .replace(/\\\./g, "\\1")
    .split(/\./)
    .map(function (part) {
      return part
        .replace(/\\1/g, ".")
        .replace(/\\2LITERAL\.LITERAL\\2/g, "\\1");
    });
};

const parse = function (content) {
  return ini.parse(content);
};

const parse_brackets_then_curly = function (str, options = {}) {
  const data = {};
  let current = data;
  let stack = [current];
  const comment = options.comment || ";";
  utils.string.lines(str).forEach(function (line) {
    if (!line || line.match(/^\s*$/)) {
      return;
    }
    // Category level 1
    let match;
    if ((match = line.match(/^\s*\[(.+?)\]\s*$/))) {
      const key = match[1];
      current = data[key] = {};
      return (stack = [current]);
    } else if ((match = line.match(/^\s*(.+?)\s*=\s*\{\s*$/))) {
      // Add a child
      const parent = stack[stack.length - 1];
      parent[match[1]] = current = {};
      return stack.push(current);
    } else if ((match = line.match(/^\s*\}\s*$/))) {
      if (stack.length === 0) {
        throw Error('Invalid Syntax: found extra "}"');
      }
      stack.pop();
      return (current = stack[stack.length - 1]);
      // comment
    } else if (
      comment &&
      (match = line.match(RegExp(`^\\s*(${comment}.*)$`)))
    ) {
      return (current[match[1]] = null);
      // key value
    } else if ((match = line.match(/^\s*(.+?)\s*=\s*(.+)\s*$/))) {
      let textmatch;
      if ((textmatch = match[2].match(/^"(.*)"$/))) {
        match[2] = textmatch[1].replace('\\"', '"');
      }
      return (current[match[1]] = match[2]);
      // else
    } else if ((match = line.match(/^\s*(.+?)\s*$/))) {
      return (current[match[1]] = null);
    }
  });
  return data;
};

/*

Each category is surrounded by one or several square brackets. The number of brackets indicates
the depth of the category.

Options are:

- `comment`   Default to ";"

*/
const parse_multi_brackets = function (str, options = {}) {
  const data = {};
  let current = data;
  const stack = [current];
  const comment = options.comment || ";";
  utils.string.lines(str).forEach(function (line) {
    let match;
    if (!line || line.match(/^\s*$/)) {
      return;
    }
    // Category
    if ((match = line.match(/^\s*(\[+)(.+?)(\]+)\s*$/))) {
      const depth = match[1].length;
      // Add a child
      if (depth === stack.length) {
        const parent = stack[depth - 1];
        parent[match[2]] = current = {};
        stack.push(current);
      }
      // Invalid child hierarchy
      if (depth > stack.length) {
        throw Error(`Invalid child ${match[2]}`);
      }
      // Move up or at the same level
      if (depth < stack.length) {
        stack.splice(depth, stack.length - depth);
        const parent = stack[depth - 1];
        parent[match[2]] = current = {};
        return stack.push(current);
      }
      // comment
    } else if (
      comment &&
      (match = line.match(RegExp(`^\\s*(${comment}.*)$`)))
    ) {
      return (current[match[1]] = null);
      // key value
    } else if ((match = line.match(/^\s*(.+?)\s*=\s*(.+)\s*$/))) {
      return (current[match[1]] = match[2]);
      // else
    } else if ((match = line.match(/^\s*(.+?)\s*$/))) {
      return (current[match[1]] = null);
    }
  });
  return data;
};

/*
Same as the parse_multi_brackets instead it takes in count values which are defined on several lines
As an example the ambari-agent .ini configuration file

*   `comment`   Default to ";"

*/
const parse_multi_brackets_multi_lines = function (str, options = {}) {
  const data = {};
  let current = data;
  const stack = [current];
  const comment = options.comment || ";";
  let writing = false;
  let previous = {};
  utils.string.lines(str).forEach(function (line, _, __) {
    if (!line || line.match(/^\s*$/)) {
      return;
    }
    let match, parent;
    // Category
    if ((match = line.match(/^\s*(\[+)(.+?)(\]+)\s*$/))) {
      const depth = match[1].length;
      // Add a child
      if (depth === stack.length) {
        parent = stack[depth - 1];
        parent[match[2]] = current = {};
        stack.push(current);
      }
      // Invalid child hierarchy
      if (depth > stack.length) {
        throw Error(`Invalid child ${match[2]}`);
      }
      // Move up or at the same level
      if (depth < stack.length) {
        stack.splice(depth, stack.length - depth);
        parent = stack[depth - 1];
        parent[match[2]] = current = {};
        return stack.push(current);
      }
      // comment
    } else if (
      comment &&
      (match = line.match(RegExp(`^\\s*(${comment}.*)$`)))
    ) {
      writing = false;
      return (current[match[1]] = null);
      // key value
    } else if ((match = line.match(/^\s*(.+?)\s*=\s*(.+)\s*$/))) {
      writing = false;
      current[match[1]] = match[2];
      previous = match[1];
      return (writing = true);
      // else
    } else if ((match = line.match(/^\s*(.+?)\s*$/))) {
      if (writing) {
        return (current[previous] += match[1]);
      } else {
        return (current[match[1]] = null);
      }
    }
  });
  return data;
};

// same as ini parse but transform value which are true and type of true as ''
// to be user by stringify_single_key
const stringify = function (obj, section, options = {}) {
  if (arguments.length === 2) {
    options = section;
    section = undefined;
  }
  if (options.separator == null) {
    options.separator = " = ";
  }
  if (options.eol == null) {
    options.eol = !options.ssh && process.platform === "win32" ? "\r\n" : "\n";
  }
  if (options.escape == null) {
    options.escape = true;
  }
  const children = [];
  let out = "";
  Object.keys(obj).forEach(function (k) {
    const val = obj[k];
    if (Array.isArray(val)) {
      return val.forEach(function (item) {
        return (out +=
          safe(`${k}[]`) + options.separator + safe(item) + options.eol);
      });
    } else if (val && typeof val === "object") {
      return children.push(k);
    } else if (typeof val === "boolean") {
      if (val === true) {
        return (out += safe(k) + options.eol);
      } else {
      }
    } else {
      // disregard false value
      return (out += safe(k) + options.separator + safe(val) + options.eol);
    }
  });
  if (section && out.length) {
    out = "[" + safe(section) + "]" + options.eol + out;
  }
  children.forEach(function (k) {
    // escape the section name dot as some daemon could not parse it
    const nk = options.escape ? split_by_dots(k).join("\\.") : k;
    const child = stringify(
      obj[k],
      (section ? section + "." : "") + nk,
      options
    );
    if (out.length && child.length) {
      out += options.eol;
    }
    return (out += child);
  });
  return out;
};

// works like stringify but write only the key when the value is ''
// be careful when using ini.parse is parses single key line as key = true
const stringify_single_key = function (obj, section, options = {}) {
  if (arguments.length === 2) {
    options = section;
    section = undefined;
  }
  if (options.separator == null) {
    options.separator = " = ";
  }
  if (options.eol == null) {
    options.eol = !options.ssh && process.platform === "win32" ? "\r\n" : "\n";
  }
  const children = [];
  let out = "";
  Object.keys(obj).forEach(function (k) {
    const val = obj[k];
    if (val && Array.isArray(val)) {
      return val.forEach(function (item) {
        return (out +=
          val === "" || val === true
            ? `${k}` + "\n"
            : safe(`${k}[]`) + options.separator + safe(item) + "\n");
      });
    } else if (val && typeof val === "object") {
      return children.push(k);
    } else {
      return (out +=
        val === "" || val === true
          ? `${k}` + options.eol
          : safe(k) + options.separator + safe(val) + options.eol);
    }
  });
  if (section && out.length) {
    out = "[" + safe(section) + "]" + options.eol + out;
  }
  children.forEach(function (k) {
    const nk = split_by_dots(k).join("\\.");
    const child = stringify_single_key(
      obj[k],
      (section ? section + "." : "") + nk,
      options
    );
    if (out.length && child.length) {
      out += options.eol;
    }
    return (out += child);
  });
  return out;
};

const stringify_brackets_then_curly = function (
  content,
  depth = 0,
  options = {}
) {
  if (arguments.length === 2) {
    options = depth;
    depth = 0;
  }
  if (options.separator == null) {
    options.separator = " = ";
  }
  if (options.eol == null) {
    options.eol = !options.ssh && process.platform === "win32" ? "\r\n" : "\n";
  }
  let out = "";
  const indent = " ";
  const prefix = indent.repeat(depth);
  for (const k in content) {
    const v = content[k];
    // isUndefined = typeof v is 'undefined'
    const isBoolean = typeof v === "boolean";
    const isNull = v === null;
    const isArray = Array.isArray(v);
    const isObj = typeof v === "object" && !isNull && !isArray;
    if (isObj) {
      if (depth === 0) {
        out += `${prefix}[${k}]${options.eol}`;
        out += stringify_brackets_then_curly(
          v,
          depth + 1,
          options
        );
        out += `${options.eol}`;
      } else {
        out += `${prefix}${k}${options.separator}{${options.eol}`;
        out += stringify_brackets_then_curly(
          v,
          depth + 1,
          options
        );
        out += `${prefix}}${options.eol}`;
      }
    } else {
      if (isArray) {
        out += v
          .map((v) => `${prefix}${k}${options.separator}${v}`)
          .join(`${options.eol}`);
      } else if (isNull) {
        out += `${prefix}${k}${options.separator}null`;
      } else if (isBoolean) {
        out += `${prefix}${k}${options.separator}${v ? "true" : "false"}`;
      } else {
        out += `${prefix}${k}${options.separator}${v}`;
      }
      out += `${options.eol}`;
    }
  }
  return out;
};

/*
Each category is surrounded by one or several square brackets. The number of brackets indicates
the depth of the category.
Taking now indent option into consideration: some file are indent aware ambari-agent .ini file
*/
const stringify_multi_brackets = function (content, depth = 0, options = {}) {
  if (arguments.length === 2) {
    options = depth;
    depth = 0;
  }
  if (options.separator == null) {
    options.separator = " = ";
  }
  if (options.eol == null) {
    options.eol = !options.ssh && process.platform === "win32" ? "\r\n" : "\n";
  }
  let out = "";
  const indent = options.indent != null ? options.indent : "  ";
  const prefix = indent.repeat(depth);
  for (const k in content) {
    const v = content[k];
    const isBoolean = typeof v === "boolean";
    const isNull = v === null;
    const isArray = Array.isArray(v);
    const isObj = typeof v === "object" && !isArray && !isNull;
    if (isObj) {
      continue;
    }
    if (isNull) {
      out += `${prefix}${k}`;
    } else if (isBoolean) {
      out += `${prefix}${k}${options.separator}${v ? "true" : "false"}`;
    } else if (isArray) {
      out += v
        .filter(function (vv) {
          return vv != null;
        })
        .map(function (vv) {
          if (typeof vv !== "string") {
            throw Error(
              `Stringify Invalid Value: expect a string for key ${k}, got ${vv}`
            );
          }
          return `${prefix}${k}${options.separator}${vv}`;
        })
        .join(options.eol);
    } else {
      out += `${prefix}${k}${options.separator}${v}`;
    }
    out += `${options.eol}`;
  }
  for (const k in content) {
    const v = content[k];
    const isNull = v === null;
    const isArray = Array.isArray(v);
    const isObj = typeof v === "object" && !isArray && !isNull;
    if (!isObj) {
      continue;
    }
    // out += "#{prefix}#{utils.string.repeat '[', depth+1}#{k}#{utils.string.repeat ']', depth+1}#{options.eol}"
    out += `${prefix}${"[".repeat(depth + 1)}${k}${"]".repeat(depth + 1)}${
      options.eol
    }`;
    out += stringify_multi_brackets(v, depth + 1, options);
  }
  return out;
};

export {
  safe,
  split_by_dots,
  parse,
  parse_brackets_then_curly,
  parse_multi_brackets,
  parse_multi_brackets_multi_lines,
  stringify,
  stringify_single_key,
  stringify_brackets_then_curly,
};

export default {
  safe: safe,
  split_by_dots: split_by_dots,
  parse: parse,
  parse_brackets_then_curly: parse_brackets_then_curly,
  parse_multi_brackets: parse_multi_brackets,
  parse_multi_brackets_multi_lines: parse_multi_brackets_multi_lines,
  stringify: stringify,
  stringify_single_key: stringify_single_key,
  stringify_brackets_then_curly: stringify_brackets_then_curly,
  stringify_multi_brackets: stringify_multi_brackets,
};
