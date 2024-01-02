import utils from "@nikitajs/core/utils";

export default {
  keyword: "cast_code",
  type: ["integer", "string", "array", "object"],
  compile: () => (data, schema) => {
    let code = data;
    if (typeof code === "undefined") {
      code = 0;
    }
    if (typeof code === "number") {
      code = [code];
    } else if (typeof code === "string") {
      code = code.split(/[ ,]/);
    }
    if (Array.isArray(code)) {
      const [t, ...f] = code;
      code = {
        true: t,
        false: f,
      };
    }
    if (code !== null) {
      code.true ??= [];
      if (!Array.isArray(code.true)) {
        code.true = [code.true];
      }
      code.false ??= [];
      if (!Array.isArray(code.false)) {
        code.false = [code.false];
      }
    }
    code.true = utils.array.flatten(code.true);
    code.true = code.true.map((c) => parseInt(c, 10));
    code.false = utils.array.flatten(code.false);
    code.false = code.false.map((c) => parseInt(c, 10));
    schema.parentData[schema.parentDataProperty] = code;
    return true;
  },
  metaSchema: {
    type: "boolean",
    enum: [true],
  },
};
