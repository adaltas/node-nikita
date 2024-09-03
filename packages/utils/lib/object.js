import { is_object_literal, merge } from "mixme";
import array from "./array.js";
import error from "./error.js";
import regexp from "./regexp.js";
import { snake_case as snake_case_str } from "./string.js";

const clean = function (content, undefinedOnly) {
  for (const k in content) {
    const v = content[k];
    if (v && typeof v === "object") {
      clean(v, undefinedOnly);
      continue;
    }
    if (typeof v === "undefined") {
      delete content[k];
    }
    if (!undefinedOnly && v === null) {
      delete content[k];
    }
  }
  return content;
};

const copy = function (source, properties) {
  const obj = {};
  for (const property of properties) {
    if (source[property] !== undefined) {
      obj[property] = source[property];
    }
  }
  return obj;
};

const diff = function (obj1, obj2, keys) {
  if (!keys) {
    const keys1 = Object.keys(obj1);
    const keys2 = Object.keys(obj2);
    keys = array.merge(keys1, keys2, array.unique(keys1));
  }
  const diff = {};
  for (const k in obj1) {
    const v = obj1[k];
    if (!(keys.indexOf(k) >= 0)) {
      continue;
    }
    if (obj2[k] === v) {
      continue;
    }
    diff[k] = [];
    diff[k][0] = v;
  }
  for (const k in obj2) {
    const v = obj2[k];
    if (!(keys.indexOf(k) >= 0)) {
      continue;
    }
    if (obj1[k] === v) {
      continue;
    }
    if (diff[k] == null) {
      diff[k] = [];
    }
    diff[k][1] = v;
  }
  return diff;
};

// equals: (obj1, obj2, keys) ->
//   keys1 = Object.keys obj1
//   keys2 = Object.keys obj2
//   if keys
//     keys1 = keys1.filter (k) -> keys.indexOf(k) isnt -1
//     keys2 = keys2.filter (k) -> keys.indexOf(k) isnt -1
//   else keys = keys1
//   return false if keys1.length isnt keys2.length
//   for k in keys
//     return false if obj1[k] isnt obj2[k]
//   return true

const insert = function (source, keys, value) {
  const result = source;
  if (!is_object_literal(source)) {
    throw error("NIKITA_UTILS_INSERT", [
      "Source must be an object literal,"`got ${JSON.stringify(source)}`,
    ]);
  }
  for (let i = 0; i < keys.length; i++) {
    const key = keys[i];
    if (source[key] === undefined) {
      // source = source[key] = {};
      source[key] = {};
    }
    if (!is_object_literal(source[key])) {
      throw error("NIKITA_UTILS_INSERT", [
        `Invalid source at path ${keys.slice(0, i)},`,
        "it must be an object or undefined,",
        `got ${JSON.stringify(source[key])}`,
      ]);
    }
    if (i === keys.length - 1) {
      source[key] = merge(source[key], value);
    } else {
      source = source[key];
    }
  }
  return result;
};

const match = function (source, target) {
  if (is_object_literal(target)) {
    if (!is_object_literal(source)) {
      return false;
    }
    for (const k in target) {
      const v = target[k];
      if (!match(source[k], v)) {
        return false;
      }
    }
    return true;
  } else if (Array.isArray(target)) {
    if (!Array.isArray(source)) {
      return false;
    }
    if (target.length !== source.length) {
      return false;
    }
    for (const i in target) {
      const v = target[i];
      if (!match(source[i], v)) {
        return false;
      }
    }
    return true;
  } else if (typeof source === "string") {
    if (regexp.is(target)) {
      return target.test(source);
    } else if (Buffer.isBuffer(target)) {
      return target.equals(Buffer.from(source));
    } else {
      return source === target;
    }
  } else if (Buffer.isBuffer(source)) {
    if (Buffer.isBuffer(target)) {
      return source.equals(target);
    } else if (typeof target === "string") {
      return source.equals(Buffer.from(target));
    } else {
      return false;
    }
  } else {
    return source === target;
  }
};

const filter = function (source, black, white) {
  if (black == null) {
    black = [];
  }
  const obj = {};
  // If white list, only use the selected list
  // Otherwise clone it all
  for (const key of white ?? Object.keys(source)) {
    if (
      Object.prototype.hasOwnProperty.call(source, key) &&
      !black.includes(key)
    ) {
      // unless part of black list
      obj[key] = source[key];
    }
  }
  return obj;
};

const snake_case = function (source) {
  const obj = {};
  for (const key in source) {
    const value = source[key];
    obj[snake_case_str(key)] = value;
  }
  return obj;
};

const trim = function (obj) {
  const result = {};
  for (const k in obj) {
    const v = obj[k];
    result[k.trim()] = typeof v === "string" ? v.trim() : v;
  }
  return result;
};

export { clean, copy, diff, insert, match, filter, snake_case, trim };

export default {
  clean: clean,
  copy: copy,
  diff: diff,
  insert: insert,
  match: match,
  filter: filter,
  snake_case: snake_case,
  trim: trim,
};
