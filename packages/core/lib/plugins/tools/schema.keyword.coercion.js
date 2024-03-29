
import codegen from 'ajv/dist/compile/codegen/index.js';
import errors from 'ajv/dist/compile/errors.js';

export default {
  keyword: "coercion",
  modifying: true,
  code: (cxt) => {
    const assignParentData = function (
      { gen, parentData, parentDataProperty },
      expr
    ) {
      gen.if(codegen._`${parentData} !== undefined`, () =>
        gen.assign(codegen._`${parentData}[${parentDataProperty}]`, expr)
      );
    };
    const { data, gen, parentSchema, it } = cxt;
    const coerced = gen.let("coerced", codegen._`undefined`);
    const types = Array.isArray(parentSchema.type)
      ? parentSchema.type
      : [parentSchema.type];
    switch (types[0]) {
      case "array":
        gen.if(codegen._`!Array.isArray(${data})`, () => {
          gen.assign(coerced, codegen._`[${data}]`);
        });
        break;
      case "boolean":
        gen.if(
          codegen._`typeof ${data} === "string" || typeof ${data} === "number"`,
          () => {
            gen.assign(coerced, codegen._`${data} != ""`);
          }
        );
        break;
      case "number":
      case "integer":
        gen.if(codegen._`typeof ${data} === "string"`, () => {
          gen.if(
            codegen._`isNaN(${data})`,
            () => {
              errors.reportError(cxt, {
                message: `fail to convert string to ${types[0]}`,
                params: ({ data }) => codegen._`{value: ${data}}`,
              });
            },
            () => {
              gen.assign(coerced, codegen._`+${data}`);
            }
          );
        });
        break;
      case "string":
        // Not, boolean coercion should not be enabled by default but with
        // `{..., coercion: ["boolean_to_string"] }`
        // Or:
        // `{..., coercion: {boolean_to_string: true} }`
        gen.if(codegen._`typeof ${data} === "boolean"`, () => {
          gen.assign(coerced, codegen._`${data} ? "1" : ""`);
        });
        gen.if(codegen._`typeof ${data} === "number"`, () => {
          gen.assign(coerced, codegen._`"" +${data}`);
        });
        break;
    }
    gen.if(codegen._`${coerced} !== undefined`, () => {
      gen.assign(data, coerced);
      assignParentData(it, coerced);
    });
  },
  metaSchema: {
    type: "boolean",
    enum: [true],
  },
};
