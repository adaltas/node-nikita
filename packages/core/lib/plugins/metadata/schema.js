
/*
# Plugin `@nikitajs/core/lib/plugins/metadata/schema`

The plugin enrich the config object with default values defined in the JSON
schema. Thus, it mst be defined after every module which modify the config
object.
*/

// Dependencies
const dedent = require('dedent');
const {mutate} = require('mixme');
const utils = require('../../utils');

module.exports = {
  name: '@nikitajs/core/lib/plugins/metadata/schema',
  require: [
    '@nikitajs/core/lib/plugins/tools/schema'
  ],
  hooks: {
    'nikita:schema': function({schema}) {
      mutate(schema.definitions.metadata.properties, {
        definitions: {
          type: 'object',
          description: dedent`
            Schema definition or \`false\` to disable schema validation in the
            current action.
          `
        }
      });
    },
    'nikita:action': {
      after: [
        '@nikitajs/core/lib/plugins/global',
        '@nikitajs/core/lib/plugins/metadata/disabled'
      ],
      handler: async function(action) {
        if (action.metadata.schema === false) {
          return;
        }
        const error = await action.tools.schema.validate(action);
        if (error) {
          throw error;
        }
      }
    }
  }
};
