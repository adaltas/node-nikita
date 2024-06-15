const NikitaError = class NikitaError extends Error {
  constructor(code, message, ...contexts) {
    if (Array.isArray(message)) {
      message = message
        .filter(function (line) {
          return !!line;
        })
        .join(" ");
    }
    message = `${code}: ${message}`;
    super(message);
    if (Error.captureStackTrace) {
      Error.captureStackTrace(this, NikitaError);
    }
    this.code = code;
    for (const context of contexts) {
      for (const key in context) {
        if (key === "code") {
          continue;
        }
        const value = context[key];
        if (value === undefined) {
          continue;
        }
        this[key] = Buffer.isBuffer(value)
          ? value.toString()
          : value === null
          ? value
          : JSON.parse(JSON.stringify(value));
      }
    }
  }
};

const error = function () {
  return new NikitaError(...arguments);
};

const got = function (value, { depth = 0, max_depth = 3 } = {}) {
  switch (typeof value) {
    case "function":
      return "function";
    case "object":
      if (Array.isArray(value)) {
        const out = [];
        for (const el of value) {
          if (depth === max_depth) {
            out.push("\u2026");
          } else {
            out.push(
              got(el, {
                depth: depth + 1,
                max_depth: max_depth,
              })
            );
          }
        }
        return `[${out.join(",")}]`;
      } else {
        return JSON.stringify(value);
      }
    default:
      return JSON.stringify(value);
  }
};

error.got = got;

export { got };

export default error;
