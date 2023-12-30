/*
The plugin enrich the config object with default values defined in the JSON
schema. Thus, it mst be defined after every module which modify the config
object.
*/

import stream from 'node:stream';
import dedent from 'dedent';
import {merge, mutate} from 'mixme';
import Ajv from 'ajv';
import ajv_keywords from 'ajv-keywords';
import ajv_formats from "ajv-formats";
import utils from '@nikitajs/core/utils';
import instanceofDef from 'ajv-keywords/dist/definitions/instanceof.js';

instanceofDef.CONSTRUCTORS['Error'] = Error;
instanceofDef.CONSTRUCTORS['stream.Writable'] = stream.Writable;
instanceofDef.CONSTRUCTORS['stream.Readable'] = stream.Readable;

const parse = function(uri) {
  const matches = /^(\w+:)\/\/(.*)/.exec(uri);
  if (!matches) {
    throw utils.error('NIKITA_SCHEMA_MALFORMED_URI', ['uri must start with a valid protocol', 'such as "module://" or "registry://",', `got ${JSON.stringify(uri)}.`]);
  }
  return {
    protocol: matches[1],
    pathname: matches[2]
  };
};

export default {
  name: '@nikitajs/core/plugins/tools/schema',
  hooks: {
    'nikita:normalize': {
      handler: async function(action) {
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
          coerceTypes: 'array',
          loadSchema: (uri) =>
            new Promise(async function(accept, reject) {
              let pathname, protocol;
              try {
                ({protocol, pathname} = parse(uri));
              } catch (error) {
                return reject(error);
              }
              switch (protocol) {
                case 'module:':
                  try {
                    const act = (await import(pathname)).default;
                    return accept({
                      definitions: act.metadata.definitions
                    });
                  } catch (error) {
                    return reject(utils.error('NIKITA_SCHEMA_INVALID_MODULE', [
                      'the module location is not resolvable,',
                      `module name is ${JSON.stringify(pathname)},`,
                      `error message is ${JSON.stringify(error.message)}.`
                    ]));
                  }
                  break;
                case 'registry:':
                  const module = pathname.split('/');
                  const act = await action.registry.get(module);
                  if (act) {
                    return accept({
                      definitions: act.metadata.definitions
                    });
                  } else {
                    return reject(utils.error('NIKITA_SCHEMA_UNREGISTERED_ACTION', ['the action is not registered inside the Nikita registry,', `action namespace is ${JSON.stringify(module.join('.'))}.`]));
                  }
                  break;
                default:
                  return reject(utils.error('NIKITA_SCHEMA_UNSUPPORTED_PROTOCOL', ['the $ref instruction reference an unsupported protocol,', `got ${JSON.stringify(protocol)}.`]));
              }
            }),
        });
        ajv_keywords(ajv);
        ajv_formats(ajv);
        ajv.addKeyword({
          keyword: "filemode",
          type: ['integer', 'string'],
          compile: () => (data, schema) => {
            if (typeof data === 'string' && /^\d+$/.test(data)) {
              schema.parentData[schema.parentDataProperty] = parseInt(data, 8);
            }
            return true;
          },
          metaSchema: {
            type: 'boolean',
            enum: [true]
          }
        });
        // Note, this is currently tested in action.execute.config_code
        ajv.addKeyword({
          keyword: "cast_code",
          type: ['integer', 'string', 'array', 'object'],
          compile: () => (data, schema) => {
            let code = data;
            if (typeof code === 'undefined') {
              code = 0;
            }
            if (typeof code === 'number') {
              code = [code];
            } else if (typeof code === 'string') {
              code = code.split(/[ ,]/);
            }
            if (Array.isArray(code)) {
              const [t, ...f] = code;
              code = {
                true: t,
                false: f
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
            type: 'boolean',
            enum: [true]
          }
        });
        action.tools.schema = {
          ajv: ajv,
          add: (schema, name) => ajv.addSchema(schema, name),
          addMetadata: (name, future) => {
            let schema = ajv.getSchema('nikita').schema;
            const current = schema.definitions.metadata.properties[name];
            if (utils.object.match(current, future)) {
              return false;
            }
            ajv.removeSchema('nikita');
            schema = merge(schema, {
              definitions: {
                metadata: {
                  properties: {
                    [name]: future
                  }
                }
              }
            });
            ajv.addSchema(schema, 'nikita');
            return true;
          },
          validate: async (action, schema) => {
            let validate;
            try {
              if (schema == null) {
                schema = action.metadata.definitions;
              }
              schema = {
                definitions: schema,
                type: 'object',
                allOf: [
                  {
                    properties: (() => {
                      const obj = {};
                      for (const k in schema) {
                        obj[k] = {
                          $ref: `#/definitions/${k}`
                        };
                      }
                      return obj;
                    })()
                  },
                  {
                    properties: {
                      metadata: {
                        $ref: 'nikita#/definitions/metadata'
                      }
                    }
                  }
                ]
              };
              validate = await ajv.compileAsync(schema);
            } catch (error) {
              if (!error.code) {
                return utils.error('NIKITA_SCHEMA_INVALID_DEFINITION', [
                  'schema failed to compile in ',
                  action.metadata.namespace.length
                  ? `action \`${action.metadata.namespace.join('.')}\``
                  : "root action",
                  action.metadata.namespace.join('.') === 'call' && action.metadata.module !== '@nikitajs/core/actions/call'
                  ? ` in module ${action.metadata.module}`
                  : undefined,
                  ', ',
                  error.message
                ].join('') + '.');
              } else {
                return error;
              }
            }
            if (validate(utils.object.filter(action, ['error', 'output']))) {
              return;
            }
            return utils.error('NIKITA_SCHEMA_VALIDATION_CONFIG', [
              validate.errors.length === 1
              ? 'one error was found in the configuration of '
              : 'multiple errors were found in the configuration of ',
              action.metadata.namespace.length
              ? `action \`${action.metadata.namespace.join('.')}\``
              : "root action",
              action.metadata.namespace.join('.') === 'call' && action.metadata.module !== '@nikitajs/core/actions/call'
              ? ` in module ${action.metadata.module}`
              : undefined,
              ':',
              validate.errors.map( (err) => {
                let msg =
                  ' ' + err.schemaPath + ' ' +
                  ajv.errorsText([err]).replace(/^data\//, '');
                for(const key in err.params){
                  if(key === 'missingProperty') continue;
                  msg += `, ${key} is ${JSON.stringify(err.params[key])}`
                }
                return msg;
              }).sort().join(';')
            ].join('') + '.');
          }
        };
        await action.plugins.call({
          name: 'nikita:schema',
          args: {
            action: action,
            ajv: ajv,
            schema: {
              definitions: {
                metadata: {
                  type: 'object',
                  properties: {}
                },
                tools: {
                  type: 'object',
                  properties: {}
                }
              }
            }
          },
          // TODO: write a test and document before activation
          // hooks: action.hooks['nikita:schema']
          handler: ({ajv, schema}) => ajv.addSchema(schema, 'nikita')
        });
      }
    },
    'nikita:schema': function({schema}) {
      return mutate(schema.definitions.metadata.properties, {
        schema: {
          type: 'boolean',
          default: true,
          description: dedent`
            Set to \`false\` to disable schema validation in the current
            action.
          `
        }
      });
    }
  }
};
