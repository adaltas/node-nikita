
// parse the content of tmpfs daemon configuration file
import string from "@nikitajs/utils/string";

const properties = ['type', 'mount', 'perm', 'uid', 'gid', 'age', 'argu']

const parse = function (str) {
  const files = {};
  string.lines(str).forEach(function(line, _, __) {
    if (!line || line.match(/^#.*$/)) {
      return;
    }
    const values = line.split(/\s+/);
    const [, mount] = values;
    const record = {};
    for (const i in properties) {
      const property = properties[i];
      const value = values[i];
      record[property] = value === '-' ? undefined : value;
    }
    files[mount] = record;
  });
  return files;
};

const stringify = function (record) {
  const lines = [];
  for (const v of Object.values(record)) {
    const keys = ["mount", "perm", "uid", "gid", "age", "argu"];
    for (const key of keys) {
      v[key] = v[key] !== undefined ? v[key] : "-";
    }
    lines.push(
      `${v.type} ${v.mount} ${v.perm} ${v.uid} ${v.gid} ${v.age} ${v.argu}`
    );
  }
  return lines.join("\n");
};

export { parse, properties, stringify };

export default {
  parse: parse,
  properties: properties,
  stringify: stringify,
};
