
/*
# Plugin `@nikitajs/core/plugins/metadata/header`

The `header` plugin validate the metadata `header` property against the schema.
*/

// Dependencies
import {mutate} from 'mixme';

// Plugin
export default {
  name: '@nikitajs/core/plugins/metadata/header',
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
