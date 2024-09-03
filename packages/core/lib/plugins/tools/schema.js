/*
The plugin enrich the config object with default values defined in the JSON
schema. Thus, it mst be defined after every module which modify the config
object.
*/

import stream from "node:stream";
import dedent from "dedent";
import { merge, mutate } from "mixme";
import Ajv from "ajv/dist/2019.js";
import ajv_keywords from "ajv-keywords";
import ajv_formats from "ajv-formats";
import utils from "@nikitajs/core/utils";
import instanceofDef from "ajv-keywords/dist/definitions/instanceof.js";
import cast_code from "@nikitajs/core/plugins/tools/schema.keyword.cast_code";
import coercion from "@nikitajs/core/plugins/tools/schema.keyword.coercion";
import filemode from "@nikitajs/core/plugins/tools/schema.keyword.filemode";

instanceofDef.CONSTRUCTORS["Error"] = Error;
instanceofDef.CONSTRUCTORS["stream.Writable"] = stream.Writable;
instanceofDef.CONSTRUCTORS["stream.Readable"] = stream.Readable;

const parse = function (uri) {
  const matches = /^(\w+:)\/\/(.*)/.exec(uri);
  if (!matches) {
    throw utils.error("NIKITA_SCHEMA_MALFORMED_URI", [
      "uri must start with a valid protocol",
      'such as "module://" or "registry://",',
      `got ${JSON.stringify(uri)}.`,
    ]);
  }
  return {
    protocol: matches[1],
    pathname: matches[2],
  };
};

export default {
  name: "@nikitajs/core/plugins/tools/schema",
  hooks: {
    "nikita:normalize": {
      handler: async function (action) {
        // Handler execution
        action.tools ??= {};
        // Get schema from parent action
        if (action.parent?.tools.schema != null) {
          action.tools.schema = action.parent.tools.schema;
          return action;
        }
        // Instantiate a new schema
        const ajv = new Ajv({
          $data: true,
          allErrors: true,
          useDefaults: true,
          allowUnionTypes: true, // eg type: ['boolean', 'integer']
          strict: true,
          strictRequired: false, // see https://github.com/ajv-validator/ajv/issues/1571
          // coerceTypes: 'array',
          loadSchema: async (uri) => {
            const { protocol, pathname } = parse(uri);
            if (protocol === "module:") {
              try {
                const act = (await import(pathname)).default;
                return {
                  definitions: act.metadata.definitions,
                };
              } catch (error) {
                throw utils.error("NIKITA_SCHEMA_INVALID_MODULE", [
                  "the module location is not resolvable,",
                  `module name is ${JSON.stringify(pathname)},`,
                  `error message is ${JSON.stringify(error.message)}.`,
                ]);
              }
            } else if (protocol === "registry:") {
              const module = pathname.split("/");
              const act = await action.registry.get(module);
              if (act) {
                return {
                  definitions: act.metadata.definitions,
                };
              } else {
                throw utils.error("NIKITA_SCHEMA_UNREGISTERED_ACTION", [
                  "the action is not registered inside the Nikita registry,",
                  `action namespace is ${JSON.stringify(module.join("."))}.`,
                ]);
              }
            } else {
              throw utils.error("NIKITA_SCHEMA_UNSUPPORTED_PROTOCOL", [
                "the $ref instruction reference an unsupported protocol,",
                `got ${JSON.stringify(protocol)}.`,
              ]);
            }
          },
        });
        ajv_keywords(ajv);
        ajv_formats(ajv);
        // Note, this is currently tested in action.execute.config.code
        ajv.addKeyword(cast_code);
        ajv.addKeyword(coercion);
        ajv.addKeyword(filemode);
        action.tools.schema = {
          ajv: ajv,
          add: (schema, name) => ajv.addSchema(schema, name),
          addMetadata: (name, future) => {
            let schema = ajv.getSchema("nikita").schema;
            const current = schema.definitions.metadata.properties[name];
            if (utils.object.match(current, future)) {
              return false;
            }
            ajv.removeSchema("nikita");
            schema = merge(schema, {
              definitions: {
                metadata: {
                  properties: {
                    [name]: future,
                  },
                },
              },
            });
            ajv.addSchema(schema, "nikita");
            return true;
          },
          validate: async (action, definitions) => {
            let validate;
            try {
              if (definitions == null) {
                definitions = action.metadata.definitions;
              }
              const schema = {
                definitions: definitions,
                // definitions: {config: {}, ...definitions},
                type: "object",
                properties: {
                  config:
                    definitions?.config ?
                      {
                        type: "object",
                        // additionalProperties: false,
                        unevaluatedProperties: false,
                        $ref: "#/definitions/config",
                      }
                    : {},
                  metadata: {
                    $ref: "nikita#/definitions/metadata",
                  },
                },
              };
              validate = await ajv.compileAsync(schema);
            } catch (error) {
              if (!error.code) {
                return utils.error(
                  "NIKITA_SCHEMA_INVALID_DEFINITION",
                  [
                    "schema failed to compile in ",
                    action.metadata.namespace.length ?
                      `action \`${action.metadata.namespace.join(".")}\``
                    : "root action",
                    (
                      action.metadata.namespace.join(".") === "call" &&
                      action.metadata.module !== "@nikitajs/core/actions/call"
                    ) ?
                      ` in module ${action.metadata.module}`
                    : undefined,
                    ", ",
                    error.message,
                  ].join("") + ".",
                );
              } else {
                return error;
              }
            }
            if (validate(utils.object.filter(action, ["error", "output"]))) {
              return;
            }
            return utils.error(
              "NIKITA_SCHEMA_VALIDATION_CONFIG",
              [
                validate.errors.length === 1 ?
                  "one error was found in the configuration of "
                : "multiple errors were found in the configuration of ",
                action.metadata.namespace.length ?
                  `action \`${action.metadata.namespace.join(".")}\``
                : "root action",
                (
                  action.metadata.namespace.join(".") === "call" &&
                  action.metadata.module !== "@nikitajs/core/actions/call"
                ) ?
                  ` in module ${action.metadata.module}`
                : undefined,
                ":",
                validate.errors
                  .map((err) => {
                    let msg =
                      " " +
                      err.schemaPath +
                      " " +
                      ajv.errorsText([err]).replace(/^data\//, "");
                    for (const key in err.params) {
                      if (key === "missingProperty") continue;
                      msg += `, ${key} is ${JSON.stringify(err.params[key])}`;
                    }
                    return msg;
                  })
                  .sort()
                  .join(";"),
              ].join("") + ".",
            );
          },
        };
        // Create the `nikita:schema` hook
        await action.plugins.call({
          name: "nikita:schema",
          args: {
            action: action,
            ajv: ajv,
            schema: {
              definitions: {
                metadata: {
                  type: "object",
                  properties: {},
                },
                tools: {
                  type: "object",
                  properties: {},
                },
              },
            },
          },
          // TODO: write a test and document before activation
          // hooks: action.hooks['nikita:schema']
          handler: ({ ajv, schema }) => ajv.addSchema(schema, "nikita"),
        });
      },
    },
    "nikita:schema": function ({ schema }) {
      return mutate(schema.definitions.metadata.properties, {
        schema: {
          type: "boolean",
          default: true,
          description: dedent`
            Set to \`false\` to disable schema validation in the current
            action.
          `,
        },
      });
    },
  },
};
