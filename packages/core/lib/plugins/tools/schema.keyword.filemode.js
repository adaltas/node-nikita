export default {
  keyword: "filemode",
  type: ["integer", "string"],
  compile: () => (data, schema) => {
    if (typeof data === "string" && /^\d+$/.test(data)) {
      schema.parentData[schema.parentDataProperty] = parseInt(data, 8);
    }
    return true;
  },
  metaSchema: {
    type: "boolean",
    enum: [true],
  },
};
