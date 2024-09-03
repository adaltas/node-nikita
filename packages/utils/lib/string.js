import crypto from "node:crypto";
import { snake_case_str } from "mixme";
import yaml from "js-yaml";
import error from "./error.js";

/**
 * Escape an argument with single quotes.
 *
 * @param {*} arg
 * @returns Single quote escaped argument
 */
const escapeshellarg = function (arg) {
  const result = arg.replace(/'/g, () => "'\"'\"'");
  return `'${result}'`;
};

/*
`string.endsWith(search, [position])`

Determines whether a string ends with the characters of another string,
returning true or false as appropriate.
This method has been added to the ECMAScript 6 specification and its code
was borrowed from [Mozilla](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/endsWith)
*/
const endsWith = function (str, search, position) {
  position = position || str.length;
  position = position - search.length;
  const lastIndex = str.lastIndexOf(search);
  return lastIndex !== -1 && lastIndex === position;
};

const format = async function (data, format, args = {}) {
  const esa = this.escapeshellarg;
  const lines = this.lines;
  if (typeof format === "function") {
    try {
      return await format({
        data: data,
        ...args,
      });
    } catch (err) {
      throw error("NIKITA_UTILS_STRING_FORMAT_UDF_FAILURE", [
        "failed to format output with a user defined function,",
        `original error message is ${esa(err.message)}.`,
      ]);
    }
  } else {
    try {
      return (function () {
        switch (format) {
          case "json":
            return JSON.parse(data);
          case "jsonlines":
            return lines(data)
              .filter((line) => line.trim() !== "")
              .map(JSON.parse);
          case "lines":
            return lines(data);
          case "yaml":
            return yaml.load(data);
        }
      })();
    } catch (err) {
      throw error("NIKITA_UTILS_STRING_FORMAT_PARSING_FAILURE", [
        "failed to parse output,",
        `format is ${JSON.stringify(format)},`,
        `original error message is ${JSON.stringify(err.message)}.`,
      ]);
    }
  }
};

/*
`string.hash(file, [algorithm], callback)`

Output the hash of a supplied string in hexadecimal
form. The default algorithm to compute the hash is md5.
*/
const hash = function (data, algorithm) {
  if (arguments.length === 1) {
    algorithm = "md5";
  }
  return crypto.createHash(algorithm).update(data).digest("hex");
};

const lines = function (str) {
  return str.split(/\r\n|[\n\r\u0085\u2028\u2029]/g);
};

const max = function (str, max) {
  if (str.length > max) {
    return str.slice(0, max) + "…";
  } else {
    return str;
  }
};

const print_time = function (time) {
  if (time > 1000 * 60) {
    `${time / 1000}m`;
  }
  if (time > 1000) {
    return `${time / 1000}s`;
  } else {
    return `${time}ms`;
  }
};

const repeat = function (str, l) {
  return Array(l + 1).join(str);
};

const snake_case = snake_case_str;

export {
  escapeshellarg,
  endsWith,
  format,
  hash,
  lines,
  max,
  print_time,
  repeat,
  snake_case,
};

export default {
  escapeshellarg: escapeshellarg,
  endsWith: endsWith,
  format: format,
  hash: hash,
  lines: lines,
  max: max,
  print_time: print_time,
  repeat: repeat,
  snake_case: snake_case,
};
