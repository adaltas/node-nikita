
/*
# Plugin `@nikitajs/core/lib/plugins/metadata/header`

The `header` plugin validate the metadata `header` property against the schema.
*/
var mutate;

({mutate} = require('mixme'));

module.exports = {
  name: '@nikitajs/core/lib/plugins/metadata/header',
  hooks: {
    'nikita:schema': function({schema}) {
      mutate(schema.definitions.metadata.properties, {
        header: {
          type: 'string',
          description: `Associate a title with the current action.`
        }
      });
    }
  }
};
